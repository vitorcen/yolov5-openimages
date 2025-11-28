#!/bin/bash
# YOLOv5 v6.2 GPU Environment Setup Script (Conda)
# Usage: ./conda.sh
# This script sets up a complete GPU training environment for YOLOv5 using conda

set -e  # Exit on error

echo "========================================="
echo "YOLOv5 v6.2 GPU Environment Setup"
echo "========================================="

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo -e "${RED}Error: conda not found. Please install Miniconda or Anaconda first.${NC}"
    echo "Download from: https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

# Check NVIDIA GPU and CUDA
echo -e "\n${YELLOW}[1/6] Checking GPU and CUDA...${NC}"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    CUDA_AVAILABLE=true
else
    echo -e "${RED}Warning: nvidia-smi not found. GPU training may not be available.${NC}"
    CUDA_AVAILABLE=false
fi

# Environment name
ENV_NAME="yolov5_v62"
PYTHON_VERSION="3.8"

# Check if environment already exists
echo -e "\n${YELLOW}[2/6] Checking conda environment...${NC}"
if conda env list | grep -q "^${ENV_NAME} "; then
    echo -e "${YELLOW}Environment '${ENV_NAME}' already exists.${NC}"
    read -p "Do you want to remove and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        conda env remove -n ${ENV_NAME} -y
    else
        echo "Using existing environment."
    fi
fi

# Create conda environment if it doesn't exist
if ! conda env list | grep -q "^${ENV_NAME} "; then
    echo -e "${GREEN}Creating conda environment '${ENV_NAME}' with Python ${PYTHON_VERSION}...${NC}"
    conda create -n ${ENV_NAME} python=${PYTHON_VERSION} -y
fi

# Activate environment
echo -e "\n${YELLOW}[3/6] Activating environment...${NC}"
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate ${ENV_NAME}

# Install PyTorch with CUDA support
echo -e "\n${YELLOW}[4/6] Installing PyTorch with CUDA support...${NC}"
if [ "$CUDA_AVAILABLE" = true ]; then
    echo "Installing PyTorch with CUDA 12.1..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
else
    echo "Installing CPU-only PyTorch..."
    pip install torch torchvision torchaudio
fi

# Install YOLOv5 requirements
echo -e "\n${YELLOW}[5/6] Installing YOLOv5 requirements...${NC}"
pip install -r requirements.txt

# Verify installation
echo -e "\n${YELLOW}[6/6] Verifying installation...${NC}"
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}'); print(f'GPU count: {torch.cuda.device_count()}'); [print(f'GPU {i}: {torch.cuda.get_device_name(i)}') for i in range(torch.cuda.device_count())] if torch.cuda.is_available() else None"

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\nTo activate the environment, run:"
echo -e "  ${YELLOW}conda activate ${ENV_NAME}${NC}"
echo -e "\nTo start training, run:"
echo -e "  ${YELLOW}./train.sh${NC}"
echo ""
