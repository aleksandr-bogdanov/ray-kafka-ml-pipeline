# ray-kafka-ml-pipeline


```shell
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="eu-central-1"
export S3_BUCKET_NAME="abogdanov-ray-kafka-ml-pipeline"
export SQS_QUEUE_URL="https://sqs.eu-central-1.amazonaws.com/YOURID/abogdanov-ray-kafka-ml-pipeline"
```


```shell
poetry update
poetry install
poetry run produce
poetry run consume
```

```shell
(ray-kafka-ml-pipeline-py3.11) ➜  ray-kafka-ml-pipeline git:(master) ✗ poetry run consume

2025-01-26 18:18:33,260 INFO worker.py:1832 -- Started a local Ray instance. View the dashboard at http://127.0.0.1:8265 
{"component": "Consumer", "device": "mps", "event": "Using device"}
{"component": "Consumer", "event": "Starting consumer"}
{"component": "Consumer", "image_id": "cifar10_7", "original_label": "horse", "predicted_label": "horse", "confidence": 0.9948858618736267, "device": "mps", "event": "Processed message"}
{"component": "Consumer", "image_id": "cifar10_10", "original_label": "deer", "predicted_label": "deer", "confidence": 0.9933537244796753, "device": "mps", "event": "Processed message"}
{"component": "Consumer", "image_id": "cifar10_24", "original_label": "bird", "predicted_label": "bird", "confidence": 0.9946235418319702, "device": "mps", "event": "Processed message"}
{"component": "Consumer", "image_id": "cifar10_30", "original_label": "airplane", "predicted_label": "airplane", "confidence": 0.9947346448898315, "device": "mps", "event": "Processed message"}

```


