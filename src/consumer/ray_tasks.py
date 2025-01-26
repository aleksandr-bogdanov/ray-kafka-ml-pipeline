import ray
from PIL import Image
from consumer.models import predict


@ray.remote
def process_image(image: Image.Image, device: str) -> dict:
    return predict(image, device)
