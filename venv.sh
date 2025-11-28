#!/bin/bash
# YOLOv5 v6.2 venv Environment Setup Script
# Usage: ./venv.sh
# This script sets up a Python venv with GPU training environment for YOLOv5

set -e  # Exit on error

echo "========================================="
echo "YOLOv5 v6.2 venv GPU Environment Setup"
echo "========================================="

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Determine Python to use (prefer conda Python 3.8)
CONDA_ENV="/root/miniconda/envs/yolov5_v62"
if [ -f "${CONDA_ENV}/bin/python3" ]; then
    PYTHON_BIN="${CONDA_ENV}/bin/python3"
    echo -e "${GREEN}Found conda environment yolov5_v62, using Python 3.8${NC}"
elif command -v python3 &> /dev/null; then
    PYTHON_BIN="python3"
    echo -e "${YELLOW}Using system Python (may not be 3.8)${NC}"
else
    echo -e "${RED}Error: python3 not found. Please install Python 3.8+ first.${NC}"
    exit 1
fi

PYTHON_VERSION=$($PYTHON_BIN --version | awk '{print $2}')
echo -e "Using Python: ${GREEN}${PYTHON_VERSION}${NC}"

# Check NVIDIA GPU and CUDA
echo -e "\n${YELLOW}[1/6] Checking GPU and CUDA...${NC}"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    CUDA_AVAILABLE=true
else
    echo -e "${RED}Warning: nvidia-smi not found. GPU training may not be available.${NC}"
    CUDA_AVAILABLE=false
fi

# Environment path
VENV_PATH="/opt/pyenvs/yolov5_v62"

# Check if venv already exists
echo -e "\n${YELLOW}[2/6] Checking venv environment...${NC}"
if [ -d "${VENV_PATH}" ]; then
    echo -e "${YELLOW}venv '${VENV_PATH}' already exists.${NC}"
    read -p "Do you want to remove and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing venv..."
        rm -rf "${VENV_PATH}"
    else
        echo "Using existing venv."
        SKIP_CREATE=true
    fi
fi

# Create venv if it doesn't exist
if [ "$SKIP_CREATE" != true ]; then
    echo -e "${GREEN}Creating venv at '${VENV_PATH}'...${NC}"
    mkdir -p /opt/pyenvs
    $PYTHON_BIN -m venv "${VENV_PATH}"
fi

# Activate environment
echo -e "\n${YELLOW}[3/6] Activating venv...${NC}"
source "${VENV_PATH}/bin/activate"

# Upgrade pip
echo -e "\n${YELLOW}[4/6] Upgrading pip...${NC}"
pip install --upgrade pip

# Install PyTorch with CUDA support
echo -e "\n${YELLOW}[5/6] Installing PyTorch with CUDA support...${NC}"
if [ "$CUDA_AVAILABLE" = true ]; then
    echo "Installing PyTorch with CUDA 12.1..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
else
    echo "Installing CPU-only PyTorch..."
    pip install torch torchvision torchaudio
fi

# Install YOLOv5 requirements
echo -e "\n${YELLOW}[6/6] Installing YOLOv5 requirements...${NC}"
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo -e "${RED}Warning: requirements.txt not found in current directory.${NC}"
fi

# Verify installation
echo -e "\n${YELLOW}Verifying installation...${NC}"
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}'); print(f'GPU count: {torch.cuda.device_count()}'); [print(f'GPU {i}: {torch.cuda.get_device_name(i)}') for i in range(torch.cuda.device_count())] if torch.cuda.is_available() else None"

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\nTo activate the venv, run:"
echo -e "  ${YELLOW}source ${VENV_PATH}/bin/activate${NC}"
echo -e "\nTo start training, run:"
echo -e "  ${YELLOW}./train.sh${NC}"
echo -e "\nTo deactivate, run:"
echo -e "  ${YELLOW}deactivate${NC}"
echo ""
