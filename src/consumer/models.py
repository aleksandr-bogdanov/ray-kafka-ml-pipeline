import torch
from PIL import Image
from transformers import AutoImageProcessor, AutoModelForImageClassification

MODEL_ID = "nateraw/vit-base-patch16-224-cifar10"
CLASSES = ["airplane", "automobile", "bird", "cat", "deer", "dog", "frog", "horse", "ship", "truck"]


def predict(image: Image.Image, device: str) -> dict:
    processor = AutoImageProcessor.from_pretrained(MODEL_ID, use_fast=True)
    model = AutoModelForImageClassification.from_pretrained(MODEL_ID)
    model.to(device)
    model.eval()

    with torch.no_grad():
        inputs = processor(images=image, return_tensors="pt")
        inputs = {k: v.to(device) for k, v in inputs.items()}
        outputs = model(**inputs)
        predicted_idx = outputs.logits.argmax(-1).item()
        confidence = torch.softmax(outputs.logits, dim=-1).max().item()

    return {"predicted_label": CLASSES[predicted_idx], "confidence": float(confidence), "device": device}
