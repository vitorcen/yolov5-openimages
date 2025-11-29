# Stationery Dataset

Downloaded from Open Images Dataset using OIDv4_ToolKit.

## Statistics

- **Total Classes**: 42
- **Images per Class**: 100 (target)
- **Total Images**: 4699 (actual)
- **Training Images**: 4194
- **Validation Images**: 505

## Dataset Structure

```
stationery_4200/
├── images/
│   ├── train/
│   └── val/
├── labels/
│   ├── train/
│   └── val/
├── dataset.yaml
└── README.md
```

## Classes



## Usage with YOLOv5

```bash
# Train
python train.py \
    --img 640 \
    --batch 16 \
    --epochs 100 \
    --data datasets/processed/stationery_4200/dataset.yaml \
    --weights yolov5s.pt

# or use the custom training script
./train_stationery.sh
```

## Notes

- Some classes may have fewer images if not available in Open Images
- Class names are from the Open Images Dataset taxonomy
- Labels are in YOLO format (class_id x_center y_center width height)

## Download Date

Sun Nov 23 16:39:07 CST 2025
