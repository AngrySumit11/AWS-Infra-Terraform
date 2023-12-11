## SQS
resource "aws_sqs_queue" "course1-sqs-queues" {
  count                      = length(var.list_of_queue_names)
  name                       = "${var.list_of_queue_names[count.index]}-${var.service}-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue[count.index].arn
    maxReceiveCount     = 4
  })

  tags = {
    "Name" = "${var.list_of_queue_names[count.index]}-${var.service}-${var.environment}"
  }
}


resource "aws_sqs_queue" "deadletter_queue" {
  count                      = length(var.list_of_queue_names)
  name                       = "${var.list_of_queue_names[count.index]}-${var.service}-${var.environment}-deadletter"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
  tags = {
    "Name" = "${var.list_of_queue_names[count.index]}-${var.service}-${var.environment}-deadletter"
  }
}


resource "aws_sqs_queue_policy" "course1-sqs-queues-policy" {
  count     = length(var.list_of_queue_names)
  queue_url = aws_sqs_queue.course1-sqs-queues[count.index].id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default_policy_ID",
  "Statement": [
    {
      "Sid": "owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.course1-sqs-queues[count.index].arn}"
    }
    
  ]
}
POLICY
}

resource "aws_sqs_queue" "course1-sqs-mediaconvert" {
  name                       = "mediaconvert-status-${var.service}-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.mediaconvert_deadletter_queue.arn
    maxReceiveCount     = 4
  })

  tags = {
    "Name" = "mediaconvert-status-${var.service}-${var.environment}"
  }
}

resource "aws_sqs_queue" "mediaconvert_deadletter_queue" {
  name                       = "mediaconvert-status-${var.service}-${var.environment}-deadletter"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
  tags = {
    "Name" = "mediaconvert-status-${var.service}-${var.environment}-deadletter"
  }
}

resource "aws_sqs_queue" "firestore_event" {
  name                        = "firestore-event-fifo-sqs-${var.service}-${var.environment}.fifo"
  delay_seconds               = 0
  max_message_size            = 262144
  message_retention_seconds   = 345600
  receive_wait_time_seconds   = 0
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 30
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.firestore_event_deadletter_queue.arn
    maxReceiveCount     = 4
  })

  tags = {
    "Name" = "firestore-event-fifo-sqs-${var.service}-${var.environment}"
  }
}

resource "aws_sqs_queue" "firestore_event_deadletter_queue" {
  name                        = "firestore-event-fifo-sqs-${var.service}-${var.environment}-deadletter.fifo"
  message_retention_seconds   = 345600
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 30
  tags = {
    "Name" = "firestore-event-fifo-sqs-${var.service}-${var.environment}-deadletter"
  }
}