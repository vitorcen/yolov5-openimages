#!/bin/bash

# Define paths
WORK_DIR="/root/work/gpdla_sdk/yolov5n-v6.2"
# Point to the last checkpoint from the previous run
# UPDATE THIS PATH if the actual run directory is different (e.g. coco80_yolov5n2)
LAST_WEIGHTS="runs/train/coco80_yolov5n3/weights/last.pt"

# Target total epochs (previous 50 + new 150 = 200)
TOTAL_EPOCHS=200

# Change to the working directory
cd "$WORK_DIR"

# Activate conda environment
echo "Activating conda environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate yolov5_v62

# Check if weights exist
if [ ! -f "$LAST_WEIGHTS" ]; then
    echo "Error: Checkpoint $LAST_WEIGHTS not found!"
    echo "Please check the 'runs/train' directory for the correct folder name."
    exit 1
fi

# Run the training command (Start new training from last weights)
# We set epochs to 150 (200 total - 50 already done)
NEW_EPOCHS=150
DATA_YAML="/root/work/gpdla_sdk/yolov5n-v6.2/datasets/processed/coco80/data.yaml"
PROJECT_DIR="runs/train"
NAME="coco80_yolov5n_resume"

echo "Starting fine-tuning from $LAST_WEIGHTS for $NEW_EPOCHS epochs..."

python train.py --img 640 \
                --batch 32 \
                --epochs $NEW_EPOCHS \
                --data "$DATA_YAML" \
                --weights "$LAST_WEIGHTS" \
                --device 0 \
                --project "$PROJECT_DIR" \
                --name "$NAME" \
                --workers 8

echo "Training completed."
