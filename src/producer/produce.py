import io
import json
import os
from dataclasses import dataclass
from typing import Optional

import boto3
import structlog
import tenacity
import torchvision.datasets as datasets
from botocore.exceptions import BotoCoreError
from PIL import Image
from pydantic import BaseModel
from tqdm import tqdm

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ]
)
logger = structlog.get_logger()


class ImageMetadata(BaseModel):
    image_id: str
    s3_bucket: str
    s3_key: str
    class_label: str
    class_id: int


@dataclass
class ProducerConfig:
    s3_prefix: str = "images"
    batch_size: int = 100
    retry_attempts: int = 3


class ImageProducer:
    CIFAR10_CLASSES = [
        "airplane",
        "automobile",
        "bird",
        "cat",
        "deer",
        "dog",
        "frog",
        "horse",
        "ship",
        "truck",
    ]

    def __init__(self, config: Optional[ProducerConfig] = None):
        self.config = config or ProducerConfig()
        self.logger = logger.bind(component="ImageProducer")
        self._init_clients()

    def _init_clients(self) -> None:
        self.s3 = boto3.client("s3")
        self.sqs = boto3.client("sqs")
        self.bucket = os.environ["S3_BUCKET_NAME"]
        self.queue_url = os.environ["SQS_QUEUE_URL"]

    @tenacity.retry(
        stop=tenacity.stop_after_attempt(3),
        wait=tenacity.wait_exponential(multiplier=1, min=1, max=10),
        retry=tenacity.retry_if_exception_type(BotoCoreError),
    )
    def upload_and_send(self, image: Image.Image, label: int, image_id: str) -> None:
        try:
            img_byte_arr = io.BytesIO()
            image.save(img_byte_arr, format="PNG")

            s3_key = f"{self.config.s3_prefix}/{self.CIFAR10_CLASSES[label]}/{image_id}.png"

            self.s3.put_object(
                Bucket=self.bucket, Key=s3_key, Body=img_byte_arr.getvalue(), ContentType="image/png"
            )

            message = ImageMetadata(
                image_id=image_id,
                s3_bucket=self.bucket,
                s3_key=s3_key,
                class_label=self.CIFAR10_CLASSES[label],
                class_id=int(label),
            )

            self.sqs.send_message(QueueUrl=self.queue_url, MessageBody=message.json())

            self.logger.debug(
                "Processed image", image_id=image_id, s3_key=s3_key, class_label=self.CIFAR10_CLASSES[label]
            )

        except Exception as e:
            self.logger.error("Failed to process image", image_id=image_id, error=str(e))
            raise

    def process_cifar10(self, limit: Optional[int] = None) -> None:
        try:
            dataset = datasets.CIFAR10(root="./data", train=True, download=True)
            total = min(limit or len(dataset), len(dataset))

            self.logger.info("Starting CIFAR10 processing", total_images=total)

            for idx in tqdm(range(total), desc="Processing images", leave=False):
                image, label = dataset[idx]
                self.upload_and_send(image, label, f"cifar10_{idx}")

        except Exception as e:
            self.logger.error("Failed to process CIFAR10", error=str(e))
            raise


def main() -> None:
    required_vars = ["S3_BUCKET_NAME", "SQS_QUEUE_URL"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    if missing_vars:
        raise ValueError(f"Missing required environment variables: {missing_vars}")

    producer = ImageProducer()
    producer.process_cifar10(limit=100)


if __name__ == "__main__":
    main()
