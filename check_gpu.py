#!/usr/bin/env python3
"""
GPU Environment Verification Script for YOLOv5
"""
import sys

def check_gpu():
    print("=" * 50)
    print("GPU Environment Check")
    print("=" * 50)

    # Check Python version
    print(f"\nPython Version: {sys.version}")

    # Check PyTorch
    try:
        import torch
        print(f"\n[✓] PyTorch installed: {torch.__version__}")
    except ImportError:
        print("\n[✗] PyTorch not installed")
        return False

    # Check CUDA availability
    cuda_available = torch.cuda.is_available()
    if cuda_available:
        print(f"[✓] CUDA available: Yes")
        print(f"    CUDA version: {torch.version.cuda}")
        print(f"    cuDNN version: {torch.backends.cudnn.version()}")
    else:
        print("[✗] CUDA available: No")
        print("    Please install GPU version of PyTorch")
        return False

    # Check GPU devices
    gpu_count = torch.cuda.device_count()
    print(f"\n[✓] GPU count: {gpu_count}")

    for i in range(gpu_count):
        gpu_name = torch.cuda.get_device_name(i)
        gpu_memory = torch.cuda.get_device_properties(i).total_memory / (1024**3)
        print(f"    GPU {i}: {gpu_name}")
        print(f"           Memory: {gpu_memory:.2f} GB")

    # Test GPU computation
    print("\n[Test] GPU computation test...")
    try:
        x = torch.randn(1000, 1000).cuda()
        y = torch.randn(1000, 1000).cuda()
        z = torch.mm(x, y)
        print("[✓] GPU computation test: PASSED")
    except Exception as e:
        print(f"[✗] GPU computation test: FAILED")
        print(f"    Error: {e}")
        return False

    # Check other dependencies
    print("\n" + "=" * 50)
    print("Checking YOLOv5 Dependencies")
    print("=" * 50)

    deps = [
        'numpy',
        'opencv-python',
        'PIL',
        'yaml',
        'tqdm',
        'matplotlib',
        'tensorboard'
    ]

    for dep in deps:
        try:
            if dep == 'opencv-python':
                import cv2
                print(f"[✓] {dep}: {cv2.__version__}")
            elif dep == 'PIL':
                from PIL import Image
                print(f"[✓] {dep}: {Image.__version__}")
            elif dep == 'yaml':
                import yaml
                print(f"[✓] {dep}: {yaml.__version__}")
            else:
                mod = __import__(dep)
                version = getattr(mod, '__version__', 'unknown')
                print(f"[✓] {dep}: {version}")
        except ImportError:
            print(f"[✗] {dep}: NOT INSTALLED")

    print("\n" + "=" * 50)
    print("Environment Check Complete!")
    print("=" * 50)
    print("\nYour GPU environment is ready for YOLOv5 training!")
    return True

if __name__ == "__main__":
    success = check_gpu()
    sys.exit(0 if success else 1)
