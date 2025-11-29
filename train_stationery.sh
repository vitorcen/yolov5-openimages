#!/bin/bash
# YOLOv5 Stationery Dataset Training Script
# Usage: ./train_stationery.sh

# Activate environment
if [ -d "/root/miniconda/envs/yolov5_v62" ]; then
    echo "Activating Conda environment: yolov5_v62"
    source /root/miniconda/bin/activate yolov5_v62
elif [ -f "/opt/pyenvs/yolov5_v62/bin/activate" ]; then
    echo "Activating Venv: /opt/pyenvs/yolov5_v62"
    source /opt/pyenvs/yolov5_v62/bin/activate
else
    echo "Warning: No specific environment found. Using current environment."
fi

# Define paths
DATASET_YAML="/root/work/gpdla_sdk/yolov5n-v6.2/datasets/processed/stationery_4200/dataset.yaml"
WEIGHTS="yolov5n.pt"
IMG_SIZE=640
BATCH_SIZE=16
EPOCHS=100
DEVICE="0"

echo "Starting YOLOv5 training..."
echo "Data: $DATASET_YAML"
echo "Weights: $WEIGHTS"
echo "Device: $DEVICE"

# Ensure we are in the right directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

python train.py \
    --img $IMG_SIZE \
    --batch $BATCH_SIZE \
    --epochs $EPOCHS \
    --data "$DATASET_YAML" \
    --weights $WEIGHTS \
    --device $DEVICE

echo "Training complete."
