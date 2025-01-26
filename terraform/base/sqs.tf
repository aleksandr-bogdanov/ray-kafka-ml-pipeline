resource "aws_sqs_queue" "image_processing" {
  name          = local.global_name
  delay_seconds = 0
  max_message_size = 262144  # 256KB
  message_retention_seconds = 86400   # 1 day
  visibility_timeout_seconds = 300    # 5 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_processing_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "image_processing_dlq" {
  name = "${local.global_name}-dlq"
}