# Set the console output encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Get the directory where this script is located
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define paths (relative to script location)
$WORK_DIR = $SCRIPT_DIR
$DATA_YAML = Join-Path $SCRIPT_DIR "datasets\processed\coco80\data.yaml"
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
