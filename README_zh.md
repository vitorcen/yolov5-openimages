# YOLOv5 v6.2 GPU环境配置指南

## 概述

本项目支持两种GPU训练环境配置方式：
1. **Conda环境** (推荐) - 适合深度学习项目，依赖管理更强大
2. **venv虚拟环境** - 轻量级，适合简单部署

## 快速开始（完整流程）

```bash
# 1. 配置GPU环境（二选一）
./conda.sh              # 使用Conda（推荐）
# 或
./venv.sh              # 使用venv

# 2. 下载文具数据集
cd ../datasets
./download_stationery.sh

# 3. 开始训练
cd ../yolov5n-v6.2
conda activate yolov5_v62  # 或 source /opt/pyenvs/yolov5_v62/bin/activate
./train_stationery.sh
```

## 硬件要求

- NVIDIA GPU (支持CUDA 12.1+)
- 显存: 建议 >= 8GB (RTX 3060 或更高)
- 驱动: NVIDIA Driver 560+ (支持CUDA 12.6)

## 方案一：Conda环境 (推荐)

### 快速开始

```bash
# 一键安装
./conda.sh

# 激活环境
conda activate yolov5_v62

# 开始训练
./train.sh
```

### 手动配置

```bash
# 创建conda环境
conda create -n yolov5_v62 python=3.8 -y

# 激活环境
conda activate yolov5_v62

# 安装PyTorch with CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# 安装YOLOv5依赖
pip install -r requirements.txt
```

## 方案二：venv虚拟环境

### 快速开始

```bash
# 一键安装
./venv.sh

# 激活环境
source /opt/pyenvs/yolov5_v62/bin/activate

# 开始训练
./train.sh
```

### 手动配置

```bash
# 创建venv环境
mkdir -p /opt/pyenvs
python3 -m venv /opt/pyenvs/yolov5_v62

# 激活环境
source /opt/pyenvs/yolov5_v62/bin/activate

# 安装PyTorch with CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# 安装YOLOv5依赖
pip install -r requirements.txt
```

## 验证GPU环境

```bash
# 激活环境后运行
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
```

预期输出：
```
PyTorch: 2.4.1+cu121
CUDA available: True
GPU: NVIDIA GeForce RTX 4090
```

## 数据集准备

### Open Images 文具数据集

项目提供了自动下载Open Images文具数据集的脚本：

```bash
# 下载80类文具/办公用品数据集
cd ../datasets
./download_stationery.sh

# 下载完成后返回训练
cd ../yolov5n-v6.2
./train_stationery.sh
```

**数据集特点：**
- **80个类别**：包含文具、办公用品、电子设备等
- **目标数量**：每类100张训练图片 + 20张验证图片
- **总计约8000张图片**
- **自动组织为YOLOv5格式**

**数据集位置：** `../datasets/processed/stationery_4200/`

### 使用自定义数据集

如需使用其他数据集，编辑训练脚本中的 `DATASET_YAML` 路径。

## 训练配置

编辑 `train.sh` 或 `train_stationery.sh` 修改训练参数：

```bash
IMG_SIZE=640         # 图像尺寸
BATCH_SIZE=16        # 批次大小 (根据显存调整)
EPOCHS=300           # 训练轮数 (train.sh)
EPOCHS=100           # 训练轮数 (train_stationery.sh - 类别多，收敛快)
DEVICE="0"           # GPU设备 (0=第一块GPU, "cpu"=CPU)
```

## 常见问题

### 1. CUDA out of memory
- 减小 `BATCH_SIZE` (如 16 -> 8 -> 4)
- 减小 `IMG_SIZE` (如 640 -> 512)

### 2. nvidia-smi找不到
- 检查NVIDIA驱动是否安装
- WSL2用户需在Windows安装NVIDIA驱动

### 3. torch.cuda.is_available() 返回False
- 确认安装的是GPU版PyTorch (cu121)
- 检查CUDA版本兼容性
- 重新运行 `conda.sh` 或 `venv.sh`

### 4. Python版本问题
- **推荐**: Python 3.8 - 3.10
- YOLOv5在Python 3.11+可能有兼容性问题

### 5. 数据集下载问题
- **下载时间长**: Open Images数据集较大，预计需要数小时
- **部分类别图片不足**: 某些类别在Open Images中可能少于100张，脚本会尽量下载
- **网络连接**: 需要稳定连接访问Google Cloud Storage
- **磁盘空间**: 预留至少10GB空间存储数据集

## 脚本说明

### 环境配置脚本

| 脚本 | 用途 |
|------|------|
| `conda.sh` | Conda环境一键安装 |
| `venv.sh` | venv环境一键安装 |
| `check_gpu.py` | GPU环境验证脚本 |

### 训练脚本

| 脚本 | 用途 | 数据集 | 类别数 |
|------|------|--------|--------|
| `train.sh` | 通用训练脚本 | cat_dog_8000 | 8 |
| `train_stationery.sh` | 文具数据集训练 | stationery_4200 | 80 |

### 数据集脚本

| 脚本 | 位置 | 用途 |
|------|------|------|
| `download_stationery.sh` | `../datasets/` | 下载Open Images文具数据集 |

### 文档

| 文件 | 说明 |
|------|------|
| `README.md` | 本文档 |

## 卸载环境

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

## 技术栈

- PyTorch 2.4.1 / 2.5.1
- CUDA 12.1
- cuDNN 9.1
- Python 3.8+ / 3.13
- YOLOv5 v6.2
