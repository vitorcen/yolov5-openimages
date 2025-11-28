# Set the console output encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Define paths (Windows format for PowerShell)
$WORK_DIR = "D:\work_cv\gpdla_sdk\yolov5-6.2"
$DATA_YAML = "D:\work_cv\gpdla_sdk\datasets\processed\coco80\data.yaml"
$WEIGHTS = "yolov5n.pt"
$PROJECT_DIR = "runs/train"
$NAME = "coco80_yolov5n"

# Change to the working directory
Set-Location $WORK_DIR

# Activate conda environment
Write-Host "Activating conda environment..."
conda activate yolov5_v62

# Run the training command
Write-Host "Starting training..."
python train.py --img 640 `
                --batch 32 `
                --epochs 50 `
                --data $DATA_YAML `
                --weights $WEIGHTS `
                --device 0 `
                --project $PROJECT_DIR `
                --name $NAME `
                --workers 8

Write-Host "Training completed."
