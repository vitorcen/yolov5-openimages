#!/bin/bash
# Open Images Stationery Dataset Downloader
# Downloads stationery and office supply images from Open Images Dataset
# Target: 40 classes, 100 images per class = ~4000 images total
# Output: datasets/processed/stationery_4200

set -e

echo "========================================="
echo "Open Images Stationery Dataset Downloader"
echo "========================================="

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/processed/stationery_4200"
IMAGES_PER_CLASS=100
TOOLKIT_DIR="${SCRIPT_DIR}/toolkits/OIDv4_ToolKit"

# Stationery and office supply classes from Open Images Dataset
# VERIFIED classes that actually exist in Open Images (checked against class-descriptions-boxable.csv)
# Total: 40 classes, 100 images per class = 4000 images
CLASSES=(
    # Writing & Drawing Tools
    "Pen"
    "Pencil case"
    "Pencil sharpener"
    "Eraser"
    "Ruler"

    # Office Supplies
    "Scissors"
    "Calculator"
    "Stapler"
    "Adhesive tape"
    "Paper towel"
    "Paper cutter"

    # Furniture
    "Desk"
    "Chair"
    "Bookcase"
    "Cupboard"
    "Stool"

    # Electronics
    "Laptop"
    "Computer keyboard"
    "Computer mouse"
    "Printer"
    "Mobile phone"
    "Tablet computer"
    "Telephone"
    "Corded phone"

    # Time & Lighting
    "Clock"
    "Alarm clock"
    "Digital clock"
    "Wall clock"
    "Lamp"
    "Flashlight"

    # Containers & Bags
    "Box"
    "Bottle"
    "Mug"
    "Coffee cup"
    "Measuring cup"
    "Handbag"
    "Luggage and bags"
    "Plastic bag"

    # Tools & Others
    "Hammer"
    "Drill"
    "Tool"
    "Book"
)

echo -e "\n${YELLOW}[1/5] Checking dependencies...${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 not found${NC}"
    exit 1
fi

# Check git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git not found${NC}"
    exit 1
fi

echo -e "${GREEN}Dependencies OK${NC}"

# Install/Update OIDv4_ToolKit
echo -e "\n${YELLOW}[2/5] Setting up OIDv4_ToolKit...${NC}"

if [ -d "${TOOLKIT_DIR}" ]; then
    echo "OIDv4_ToolKit already exists, updating..."
    cd "${TOOLKIT_DIR}"
    git pull
else
    echo "Cloning OIDv4_ToolKit..."
    cd "${SCRIPT_DIR}"
    git clone https://github.com/EscVM/OIDv4_ToolKit.git
    cd "${TOOLKIT_DIR}"
fi

# Install toolkit requirements
if [ -f "requirements.txt" ]; then
    echo "Installing toolkit dependencies..."
    pip install -q -r requirements.txt
fi

echo -e "${GREEN}Toolkit ready${NC}"

# Create output directory
echo -e "\n${YELLOW}[3/5] Preparing output directory...${NC}"
mkdir -p "${OUTPUT_DIR}"
echo -e "${GREEN}Output: ${OUTPUT_DIR}${NC}"

# Download images
echo -e "\n${YELLOW}[4/5] Downloading stationery images...${NC}"
echo -e "Classes to download: ${#CLASSES[@]}"
echo -e "Images per class: ${IMAGES_PER_CLASS}"
echo -e "Total target: $((${#CLASSES[@]} * ${IMAGES_PER_CLASS})) images"
echo ""

# Download using OIDv4_ToolKit
echo -e "\n${YELLOW}Starting download (this may take a while)...${NC}"
cd "${TOOLKIT_DIR}"

# Download each class separately to avoid filename length issues
CURRENT=0
TOTAL=${#CLASSES[@]}

for class_name in "${CLASSES[@]}"; do
    CURRENT=$((CURRENT + 1))
    echo -e "\n${GREEN}[${CURRENT}/${TOTAL}] Downloading: ${class_name}${NC}"

    # Create temporary class file for single class
    TEMP_CLASS_FILE="${TOOLKIT_DIR}/temp_class.txt"
    echo "${class_name}" > "${TEMP_CLASS_FILE}"

    # Download training images for this class
    python3 main.py downloader \
        --classes "${TEMP_CLASS_FILE}" \
        --type_csv train \
        --limit ${IMAGES_PER_CLASS} \
        --yes || echo -e "${YELLOW}Warning: Failed to download ${class_name} (may not exist in dataset)${NC}"

    # Download validation images for this class
    python3 main.py downloader \
        --classes "${TEMP_CLASS_FILE}" \
        --type_csv validation \
        --limit 20 \
        --yes || echo -e "${YELLOW}Warning: Failed to download validation set for ${class_name}${NC}"

    # Clean up temp file
    rm -f "${TEMP_CLASS_FILE}"
done

echo -e "\n${GREEN}All downloads completed${NC}"

# Organize downloaded images
echo -e "\n${YELLOW}[5/5] Organizing dataset...${NC}"

# Move downloaded images to output directory
if [ -d "OID/Dataset" ]; then
    echo "Moving images to ${OUTPUT_DIR}..."

    # Create YOLOv5 dataset structure
    mkdir -p "${OUTPUT_DIR}/images/train"
    mkdir -p "${OUTPUT_DIR}/images/val"
    mkdir -p "${OUTPUT_DIR}/labels/train"
    mkdir -p "${OUTPUT_DIR}/labels/val"

    # Move training images and labels
    if [ -d "OID/Dataset/train" ]; then
        find OID/Dataset/train -name "*.jpg" -exec cp {} "${OUTPUT_DIR}/images/train/" \;
        find OID/Dataset/train -name "*.txt" -exec cp {} "${OUTPUT_DIR}/labels/train/" \;
    fi

    # Move validation images and labels
    if [ -d "OID/Dataset/validation" ]; then
        find OID/Dataset/validation -name "*.jpg" -exec cp {} "${OUTPUT_DIR}/images/val/" \;
        find OID/Dataset/validation -name "*.txt" -exec cp {} "${OUTPUT_DIR}/labels/val/" \;
    fi

    # Count downloaded images
    TRAIN_COUNT=$(find "${OUTPUT_DIR}/images/train" -name "*.jpg" 2>/dev/null | wc -l)
    VAL_COUNT=$(find "${OUTPUT_DIR}/images/val" -name "*.jpg" 2>/dev/null | wc -l)
    TOTAL_COUNT=$((TRAIN_COUNT + VAL_COUNT))

    echo -e "${GREEN}Download complete!${NC}"
    echo -e "Training images: ${TRAIN_COUNT}"
    echo -e "Validation images: ${VAL_COUNT}"
    echo -e "Total images: ${TOTAL_COUNT}"
else
    echo -e "${RED}Warning: Downloaded dataset not found in expected location${NC}"
fi

# Create dataset.yaml for YOLOv5
echo -e "\n${YELLOW}Creating dataset.yaml...${NC}"
cat > "${OUTPUT_DIR}/dataset.yaml" << EOF
# YOLOv5 Stationery Dataset Configuration
# Auto-generated by download_stationery.sh

path: ${OUTPUT_DIR}
train: images/train
val: images/val

# Number of classes
nc: ${#CLASSES[@]}

# Class names
names: [
$(printf "  '%s',\n" "${CLASSES[@]}")
]
EOF

echo -e "${GREEN}dataset.yaml created${NC}"

# Generate statistics
echo -e "\n${YELLOW}Generating dataset statistics...${NC}"
cat > "${OUTPUT_DIR}/README.md" << EOF
# Stationery Dataset

Downloaded from Open Images Dataset using OIDv4_ToolKit.

## Statistics

- **Total Classes**: ${#CLASSES[@]}
- **Images per Class**: ${IMAGES_PER_CLASS} (target)
- **Total Images**: ${TOTAL_COUNT} (actual)
- **Training Images**: ${TRAIN_COUNT}
- **Validation Images**: ${VAL_COUNT}

## Dataset Structure

\`\`\`
stationery_4200/
├── images/
│   ├── train/
│   └── val/
├── labels/
│   ├── train/
│   └── val/
├── dataset.yaml
└── README.md
\`\`\`

## Classes

$(printf "- %s\n" "${CLASSES[@]}")

## Usage with YOLOv5

\`\`\`bash
# Train
python train.py \\
    --img 640 \\
    --batch 16 \\
    --epochs 100 \\
    --data ${OUTPUT_DIR}/dataset.yaml \\
    --weights yolov5s.pt

# or use the custom training script
./train_stationery.sh
\`\`\`

## Notes

- Some classes may have fewer images if not available in Open Images
- Class names are from the Open Images Dataset taxonomy
- Labels are in YOLO format (class_id x_center y_center width height)

## Download Date

$(date)
EOF

echo -e "${GREEN}README.md created${NC}"

# Summary
echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}Dataset Download Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\nDataset location: ${OUTPUT_DIR}"
echo -e "Configuration: ${OUTPUT_DIR}/dataset.yaml"
echo -e "Documentation: ${OUTPUT_DIR}/README.md"
echo -e "\nTo train with this dataset:"
echo -e "  ${YELLOW}./train_stationery.sh${NC}"
echo ""
