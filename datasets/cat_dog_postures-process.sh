#!/bin/bash
set -e

# --- Configuration ---
DATASETS_DIR="/media/david/LK4T2/work_cv/gpdla_sdk/yolov5n-v6.2/datasets"
SOURCE_DATA_DIR="$DATASETS_DIR/processed/cat_dog_8000"
DEST_DATA_DIR="$DATASETS_DIR/processed/cat_dog_postures"
PROMPT_FILE_PATH="$DATASETS_DIR/cat_dog_postures-prompt.md"
YAML_FILE_PATH="$DEST_DATA_DIR/data.yaml"

API_URL="http://localhost:30000/v1/chat/completions"
MODEL_NAME="Qwen/Qwen3-VL-8B-Instruct-FP8"
MAX_JOBS=4

# --- Argument Parsing & Debug Mode ---
START_INDEX=1
END_INDEX=0 # 0 means no limit

if [ "$#" -eq 1 ]; then
    END_INDEX=$1
elif [ "$#" -eq 2 ]; then
    START_INDEX=$1
    END_INDEX=$2
fi

PROCESS_LIMIT=$END_INDEX # Use END_INDEX for debug mode check
if [ "$PROCESS_LIMIT" -gt 0 ]; then
    echo "--- DEBUG MODE ON ---"
fi

# --- Pre-flight Checks ---
if [ ! -d "$SOURCE_DATA_DIR" ]; then echo "Error: Source dir not found"; exit 1; fi
if [ ! -f "$PROMPT_FILE_PATH" ]; then echo "Error: Prompt file not found"; exit 1; fi
if [ ! -f "$YAML_FILE_PATH" ]; then echo "Error: YAML file not found"; exit 1; fi
if ! command -v yq &> /dev/null; then echo "Error: yq not installed"; exit 1; fi

# --- Functions ---
process_image() {
    local index="$1"
    local total="$2"
    local img_path="$3"

    # --- Renaming and Path construction ---
    local rel_path_original="${img_path#$SOURCE_DATA_DIR/images/}"
    local original_basename=$(basename "$rel_path_original")
    local extension="${original_basename##*.}"
    local name_without_ext="${original_basename%.*}"
    local name_stem=$(echo "$name_without_ext" | sed -e 's/^cat_//' -e 's/^dog_//')

    # We need the posture label before we can construct the final path
    # API Call first...
    local filename=$(basename "$img_path")
    local species=""
    if [[ "$filename" == *"cat"* ]]; then species="猫"; elif [[ "$filename" == *"dog"* ]]; then species="狗"; else
        echo "Warning: Cannot determine species for $filename. Skipping."; return; fi

    local prompt_content=$(<"$PROMPT_FILE_PATH")
    local final_prompt=${prompt_content//\{species\}/$species}
    local prompt_json=$(echo "$final_prompt" | jq -Rs .)
    local image_base64=$(base64 -w 0 "$img_path")

    local req_file=$(mktemp)
    trap 'rm -f "$req_file"' RETURN
    cat > "$req_file" <<EOF
{
  "model": "$MODEL_NAME", "messages": [ { "role": "user", "content": [ {"type": "text", "text": $prompt_json}, {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,$image_base64"}} ] } ],
  "max_tokens": 100, "temperature": 0.1
}
EOF

    local full_output=$(curl -s -w "\\n%{http_code}" -X POST "$API_URL" -H "Content-Type: application/json" -d @"$req_file")
    local http_code=$(echo "$full_output" | tail -n1)
    local response_body=$(echo "$full_output" | sed '$d')

    if [ "$http_code" -ne 200 ]; then echo "Error: API call failed for $filename."; return; fi
    local posture_label_raw=$(echo "$response_body" | jq -r '.choices[0].message.content' 2>/dev/null | grep -o '{[^{}]*"label"[^{}]*}' | jq -r '.label // empty')
    local posture_label=$(echo "$posture_label_raw" | tr -d '\r\n')
    if [ -z "$posture_label" ]; then echo "Error: Failed to parse label for $filename."; return; fi

    # Now construct the final paths
    local new_filename="${posture_label}_${name_stem}.${extension}"
    local rel_dir=$(dirname "$rel_path_original")
    local dest_img_path="$DEST_DATA_DIR/images/$rel_dir/$new_filename"
    local dest_label_path="$DEST_DATA_DIR/labels/$rel_dir/${new_filename%.*}.txt"

    if [ -f "$dest_label_path" ]; then return; fi

    echo "($index/$total) Processing $rel_path_original -> $new_filename"
    mkdir -p "$(dirname "$dest_img_path")" "$(dirname "$dest_label_path")"

    local line_number=$(grep -n -x -F "$posture_label" <(yq -r '.names | .[]' "$YAML_FILE_PATH"))
    if [ -z "$line_number" ]; then echo "Error: Posture '$posture_label' not found in YAML for $filename."; return; fi
    local new_class_id=$(($(echo "$line_number" | cut -d: -f1) - 1))

    local source_label_path="$SOURCE_DATA_DIR/labels/$rel_path_original"
    source_label_path="${source_label_path%.*}.txt"
    if [ ! -f "$source_label_path" ]; then echo "Error: Source label not found at $source_label_path"; return; fi

    local new_label_content=""
    while IFS= read -r line; do
        new_label_content+="$new_class_id ${line#* }\n"
    done < "$source_label_path"
    echo -e "$new_label_content" > "$dest_label_path"
    cp "$img_path" "$dest_img_path"
}

export -f process_image
export SOURCE_DATA_DIR DEST_DATA_DIR PROMPT_FILE_PATH YAML_FILE_PATH API_URL MODEL_NAME PROCESS_LIMIT

# --- Main Execution ---
echo "--- Starting Dataset Processing (with range and progress) ---"
echo "Source: $SOURCE_DATA_DIR"
echo "Destination: $DEST_DATA_DIR"

file_list_all=$(mktemp)
trap 'rm -f "$file_list_all"' EXIT
find "$SOURCE_DATA_DIR/images" -type f \( -name "*.jpg" -o -name "*.png" \) | sort > "$file_list_all"

file_list_ranged=$(mktemp)
trap 'rm -f "$file_list_ranged"' EXIT
if [ "$END_INDEX" -gt 0 ]; then
    sed -n "${START_INDEX},${END_INDEX}p" "$file_list_all" > "$file_list_ranged"
    echo "Processing range: $START_INDEX to $END_INDEX"
else
    sed -n "${START_INDEX},\$p" "$file_list_all" > "$file_list_ranged"
    echo "Processing range: $START_INDEX to end"
fi

NUM_TO_PROCESS=$(wc -l < "$file_list_ranged")
if [ "$NUM_TO_PROCESS" -eq 0 ]; then
    echo "No files to process in the specified range. Exiting."
    exit 0
fi
echo "Total files to process in this run: $NUM_TO_PROCESS"

# Add local index and total count to each line for processing
file_list_final=$(mktemp)
trap 'rm -f "$file_list_final"' EXIT
nl -w1 -s' ' "$file_list_ranged" | awk -v total=$NUM_TO_PROCESS '{print $1, total, $2}' > "$file_list_final"

# Use xargs to call the function with the new arguments
cat "$file_list_final" | xargs -P "$MAX_JOBS" -L 1 bash -c 'process_image "$@"' _

echo "--- Processing complete. ---"
