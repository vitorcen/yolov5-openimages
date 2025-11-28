#!/bin/bash

# Define paths (Linux format)
WORK_DIR="/root/work/gpdla_sdk/yolov5-6.2"
DATA_YAML="/root/work/gpdla_sdk/datasets/processed/coco80/data.yaml"
WEIGHTS="yolov5n.pt"
PROJECT_DIR="runs/train"
NAME="coco80_yolov5n"

# Change to the working directory
cd "$WORK_DIR"

# Activate conda environment
echo "Activating conda environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate yolov5_v62

# Run the training command
echo "Starting training..."
python train.py --img 640 \
                --batch 32 \
                --epochs 50 \
                --data "$DATA_YAML" \
                --weights "$WEIGHTS" \
                --device 0 \
                --project "$PROJECT_DIR" \
                --name "$NAME" \
                --workers 8

echo "Training completed."
