#!/bin/bash
# YOLOv5 Stationery Dataset Training Script
# Usage: ./train_stationery.sh

# 1. Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define paths
WORK_DIR="$SCRIPT_DIR"
DATASET_YAML="$SCRIPT_DIR/datasets/processed/stationery_4200/dataset.yaml"
WEIGHTS="yolov5n.pt"
IMG_SIZE=640
BATCH_SIZE=16
EPOCHS=100
DEVICE="0"

# Change to the working directory
cd "$WORK_DIR"

# Activate conda environment
echo "Activating conda environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate yolov5_v62

echo "Starting YOLOv5 training..."
echo "Data: $DATASET_YAML"
echo "Weights: $WEIGHTS"
echo "Device: $DEVICE"

python train.py \
    --img $IMG_SIZE \
    --batch $BATCH_SIZE \
    --epochs $EPOCHS \
    --data "$DATASET_YAML" \
    --weights $WEIGHTS \
    --device $DEVICE

echo "Training complete."
