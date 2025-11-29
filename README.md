[![](https://img.shields.io/badge/%F0%9F%87%A8%F0%9F%87%B3-%E4%B8%AD%E6%96%87%E7%89%88-ff0000?style=flat)](./README_zh.md)

# YOLOv5 v6.2 GPU Environment Setup Guide

## Overview

This project supports two GPU training environment configurations:
1. **Conda Environment** (Recommended) - More powerful dependency management for deep learning projects
2. **venv Virtual Environment** - Lightweight, suitable for simple deployments

## Quick Start (Complete Workflow)

```bash
# 1. Configure GPU environment (choose one)
./conda.sh              # Use Conda (recommended)
# or
./venv.sh               # Use venv

# 2. Download stationery dataset
cd ../datasets
./download_stationery.sh

# 3. Start training
cd ../yolov5n-v6.2
conda activate yolov5_v62  # or source /opt/pyenvs/yolov5_v62/bin/activate
./train_stationery.sh
```

## Hardware Requirements

- NVIDIA GPU (CUDA 12.1+ support)
- VRAM: Recommended >= 8GB (RTX 3060 or higher)
- Driver: NVIDIA Driver 560+ (supports CUDA 12.6)

## Option 1: Conda Environment (Recommended)

### Quick Start

```bash
# One-click installation
./conda.sh

# Activate environment
conda activate yolov5_v62

# Start training
./train.sh
```

### Manual Configuration

```bash
# Create conda environment
conda create -n yolov5_v62 python=3.8 -y

# Activate environment
conda activate yolov5_v62

# Install PyTorch with CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install YOLOv5 dependencies
pip install -r requirements.txt
```

## Option 2: venv Virtual Environment

### Quick Start

```bash
# One-click installation
./venv.sh

# Activate environment
source /opt/pyenvs/yolov5_v62/bin/activate

# Start training
./train.sh
```

### Manual Configuration

```bash
# Create venv environment
mkdir -p /opt/pyenvs
python3 -m venv /opt/pyenvs/yolov5_v62

# Activate environment
source /opt/pyenvs/yolov5_v62/bin/activate

# Install PyTorch with CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install YOLOv5 dependencies
pip install -r requirements.txt
```

## Verify GPU Environment

```bash
# Run after activating environment
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
```

Expected output:
```
PyTorch: 2.4.1+cu121
CUDA available: True
GPU: NVIDIA GeForce RTX 4090
```

## Dataset Preparation

### Open Images Stationery Dataset

The project provides scripts to automatically download the Open Images stationery dataset:

```bash
# Download 80-class stationery/office supplies dataset
cd ../datasets
./download_stationery.sh

# Return to training after download
cd ../yolov5n-v6.2
./train_stationery.sh
```

**Dataset Features:**
- **80 classes**: Including stationery, office supplies, electronic devices, etc.
- **Target quantity**: 100 training images + 20 validation images per class
- **Total ~8000 images**
- **Auto-organized to YOLOv5 format**

**Dataset Location:** `../datasets/processed/stationery_4200/`

### Using Custom Datasets

To use other datasets, edit the `DATASET_YAML` path in the training script.

## Training Configuration

Edit `train.sh` or `train_stationery.sh` to modify training parameters:

```bash
IMG_SIZE=640         # Image size
BATCH_SIZE=16        # Batch size (adjust based on VRAM)
EPOCHS=300           # Training epochs (train.sh)
EPOCHS=100           # Training epochs (train_stationery.sh - more classes, faster convergence)
DEVICE="0"           # GPU device (0=first GPU, "cpu"=CPU)
```

## Troubleshooting

### 1. CUDA out of memory
- Reduce `BATCH_SIZE` (e.g., 16 -> 8 -> 4)
- Reduce `IMG_SIZE` (e.g., 640 -> 512)

### 2. nvidia-smi not found
- Check if NVIDIA driver is installed
- WSL2 users need to install NVIDIA driver on Windows

### 3. torch.cuda.is_available() returns False
- Verify GPU version of PyTorch is installed (cu121)
- Check CUDA version compatibility
- Re-run `conda.sh` or `venv.sh`

### 4. Python version issues
- **Recommended**: Python 3.8 - 3.10
- YOLOv5 may have compatibility issues with Python 3.11+

### 5. Dataset download issues
- **Long download time**: Open Images dataset is large, expect several hours
- **Insufficient images for some classes**: Some classes may have fewer than 100 images in Open Images
- **Network connection**: Requires stable connection to Google Cloud Storage
- **Disk space**: Reserve at least 10GB for dataset storage

## Script Reference

### Environment Setup Scripts

| Script | Purpose |
|--------|---------|
| `conda.sh` | One-click Conda environment installation |
| `venv.sh` | One-click venv environment installation |
| `check_gpu.py` | GPU environment verification script |

### Training Scripts

| Script | Purpose | Dataset | Classes |
|--------|---------|---------|---------|
| `train.sh` | General training script | cat_dog_8000 | 8 |
| `train_stationery.sh` | Stationery dataset training | stationery_4200 | 80 |

### Dataset Scripts

| Script | Location | Purpose |
|--------|----------|---------|
| `download_stationery.sh` | `../datasets/` | Download Open Images stationery dataset |

### Documentation

| File | Description |
|------|-------------|
| `README.md` | This document (English) |
| `README_zh.md` | Chinese documentation |

## Uninstall Environment

### Conda
```bash
conda deactivate
conda env remove -n yolov5_v62
```

### venv
```bash
deactivate
rm -rf /opt/pyenvs/yolov5_v62
```

## Tech Stack

- PyTorch 2.4.1 / 2.5.1
- CUDA 12.1
- cuDNN 9.1
- Python 3.8+ / 3.13
- YOLOv5 v6.2
