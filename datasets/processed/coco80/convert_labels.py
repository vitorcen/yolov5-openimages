import json
import os
from pathlib import Path
from tqdm import tqdm
import shutil

def convert_coco_to_yolo():
    # Get the directory where this script is located
    processed_dir = Path(__file__).resolve().parent
    # Assuming datasets_raw is at /root/work/datasets_raw
    # You might want to make this configurable or relative too if possible,
    # but for now let's keep it if it's an external dependency,
    # OR if it's expected to be in a fixed location relative to the repo.
    # Given the context, let's try to make it relative to the repo if feasible,
    # or keep it as a configurable path.
    # However, the original code had it hardcoded.
    # Let's check if we can find it relative to the script.
    # If not, we might have to keep it or ask the user.
    # For this specific request, I'll change the processed_dir to be dynamic.
    # The raw_dir seems to be a separate data directory.

    # Let's use the original logic for raw_dir unless we know better,
    # but definitely fix processed_dir.
    # Actually, prepare_coco.sh sets these. Let's look at prepare_coco.sh first.
    # The prepare_coco.sh generates this file!
    # So I should edit prepare_coco.sh to generate the DYNAMIC version of this script.

    # Wait, I am editing the file directly first as requested.
    # If this file is generated, my changes might be overwritten if the script is run again.
    # But the user asked to change these specific files.

    # Let's fix the existing file to be dynamic.
    raw_dir = Path("/root/work/datasets_raw/coco")
    processed_dir = Path(__file__).resolve().parent

    # Define mappings
    splits = [
        ('annotations/instances_train2017.json', 'labels/train2017'),
        ('annotations/instances_val2017.json', 'labels/val2017')
    ]

    # Hardcoded YOLOv5 COCO labels order (matches data.yaml)
    yolo_names = [
        'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat', 'traffic light',
        'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', 'sheep', 'cow',
        'elephant', 'bear', 'zebra', 'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
        'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard',
        'tennis racket', 'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
        'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch',
        'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone',
        'microwave', 'oven', 'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear',
        'hair drier', 'toothbrush'
    ]

    for json_rel, label_rel in splits:
        json_path = raw_dir / json_rel
        label_dir = processed_dir / label_rel

        if not json_path.exists():
            print(f"Warning: {json_path} not found, skipping.")
            continue

        # Create label directory
        if label_dir.exists():
            shutil.rmtree(label_dir)
        label_dir.mkdir(parents=True, exist_ok=True)

        print(f"Loading {json_path}...")
        with open(json_path) as f:
            data = json.load(f)

        # Create category mapping
        cat_map = {}
        for cat in data['categories']:
            if cat['name'] in yolo_names:
                cat_map[cat['id']] = yolo_names.index(cat['name'])

        # Image lookup
        images = {img['id']: img for img in data['images']}

        print(f"Converting annotations to {label_dir}...")
        for ann in tqdm(data['annotations']):
            if 'bbox' not in ann: continue
            img_id = ann['image_id']
            if img_id not in images: continue

            cid = ann['category_id']
            if cid not in cat_map: continue # Skip unmapped

            class_idx = cat_map[cid]

            # Image info
            img_info = images[img_id]
            img_w = img_info['width']
            img_h = img_info['height']

            # BBox conversion
            x, y, w, h = ann['bbox']
            x_center = (x + w / 2) / img_w
            y_center = (y + h / 2) / img_h
            w_norm = w / img_w
            h_norm = h / img_h

            # Clip
            x_center = max(0.0, min(1.0, x_center))
            y_center = max(0.0, min(1.0, y_center))
            w_norm = max(0.0, min(1.0, w_norm))
            h_norm = max(0.0, min(1.0, h_norm))

            # Write to file
            fname = Path(img_info['file_name']).with_suffix('.txt').name
            with open(label_dir / fname, 'a') as f_out:
                f_out.write(f"{class_idx} {x_center:.6f} {y_center:.6f} {w_norm:.6f} {h_norm:.6f}\n")

if __name__ == '__main__':
    convert_coco_to_yolo()
