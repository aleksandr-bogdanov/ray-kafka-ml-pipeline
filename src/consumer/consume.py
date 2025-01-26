import io
import os
from typing import List, Dict

import boto3
import ray
import structlog
import torch
from PIL import Image
from pydantic import BaseModel

from consumer.ray_tasks import process_image

structlog.configure(processors=[structlog.processors.JSONRenderer()])
logger = structlog.get_logger()


class ImageMetadata(BaseModel):
    image_id: str
    s3_bucket: str
    s3_key: str
    class_label: str
    class_id: int


class Consumer:
    def __init__(self, queue_url: str):
        self.logger = logger.bind(component="Consumer")
        self.s3 = boto3.client("s3")
        self.sqs = boto3.client("sqs")
        self.queue_url = queue_url
        self.device = "mps" if torch.backends.mps.is_available() else "cpu"
        self.logger.info("Using device", device=self.device)

    def _download_image(self, bucket: str, key: str) -> Image.Image:
        response = self.s3.get_object(Bucket=bucket, Key=key)
        return Image.open(io.BytesIO(response["Body"].read()))

    def receive_messages(self, batch_size: int = 10) -> List[Dict]:
        response = self.sqs.receive_message(
            QueueUrl=self.queue_url, MaxNumberOfMessages=batch_size, WaitTimeSeconds=20, VisibilityTimeout=30
        )
        return response.get("Messages", [])

    def process_message(self, message: Dict) -> Dict:
        metadata = ImageMetadata.parse_raw(message["Body"])
        image = self._download_image(metadata.s3_bucket, metadata.s3_key)

        prediction = ray.get(process_image.remote(image, self.device))

        result = {"image_id": metadata.image_id, "original_label": metadata.class_label, **prediction}

        self.logger.info("Processed message", **result)
        return result

    def run(self, batch_size: int = 10) -> None:
        self.logger.info("Starting consumer")
        while True:
            messages = self.receive_messages(batch_size)
            if not messages:
                continue

            for message in messages:
                self.process_message(message)


def main() -> None:
    if not os.getenv("SQS_QUEUE_URL"):
        raise ValueError("Missing SQS_QUEUE_URL environment variable")

    ray.init()
    consumer = Consumer(os.getenv("SQS_QUEUE_URL"))
    consumer.run()


if __name__ == "__main__":
    main()
