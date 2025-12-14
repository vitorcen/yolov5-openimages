#!/bin/bash

# This script trains a YOLOv5 model on the cat & dog postures dataset.

# --- Configuration ---
PROJECT_NAME="cat_dog_postures_det"
MODEL_CONFIG="yolov5n.yaml" # Or yolov5s.yaml, etc.
DATA_CONFIG="datasets/processed/cat_dog_postures/data.yaml"
BATCH_SIZE=16
IMAGE_SIZE=640
EPOCHS=300
DEVICE="0" # GPU device, e.g., "0" or "0,1" or "cpu"

# --- Run Name (Auto-generated) ---
RUN_NAME="${MODEL_CONFIG%.*}_epochs${EPOCHS}_batch${BATCH_SIZE}_img${IMAGE_SIZE}"

# --- Activate conda environment ---
echo "Activating conda environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate yolov5_v62

# --- Start Training ---
echo "Starting YOLOv5 training..."
echo "  Project: $PROJECT_NAME"
echo "  Run Name: $RUN_NAME"
echo "  Model: $MODEL_CONFIG"
echo "  Data: $DATA_CONFIG"
echo "  Epochs: $EPOCHS"
echo "  Batch Size: $BATCH_SIZE"
echo "  Image Size: $IMAGE_SIZE"
echo "  Device: $DEVICE"

python train.py \
    --img $IMAGE_SIZE \
    --batch $BATCH_SIZE \
    --epochs $EPOCHS \
    --data $DATA_CONFIG \
    --cfg models/$MODEL_CONFIG \
    --weights '' \
    --project runs/train/$PROJECT_NAME \
    --name $RUN_NAME \
    --device $DEVICE

echo "Training finished. Results saved in runs/train/$PROJECT_NAME/$RUN_NAME"
