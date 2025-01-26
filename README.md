# ray-kafka-ml-pipeline


```shell
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="eu-central-1"
export S3_BUCKET_NAME="abogdanov-ray-kafka-ml-pipeline"
export SQS_QUEUE_URL="https://sqs.eu-central-1.amazonaws.com/829622384778/abogdanov-ray-kafka-ml-pipeline"
```


```shell
poetry update
poetry install
poetry run produce
poetry run consume
```