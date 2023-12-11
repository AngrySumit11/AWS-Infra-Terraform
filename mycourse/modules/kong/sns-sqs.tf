## SNS
resource "aws_sns_topic" "course1-sns-topic" {
  count           = var.create_sns_sqs ? length(var.list_of_sns_names) : 0
  name            = "${var.list_of_sns_names[count.index]}${var.env_identifier}"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
  tags = {
    "Name" = "${var.list_of_sns_names[count.index]}${var.env_identifier}"
  }
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count     = var.create_sns_sqs ? length(var.list_of_sns_names) : 0
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.course1-sns-topic[floor(count.index / 2)].arn,
    ]
    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "SNS:Publish",
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.course1-sns-topic[floor(count.index / 2)].arn,
    ]
    sid = "__console_pub_0"
  }

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:Receive"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.course1-sns-topic[floor(count.index / 2)].arn,
    ]
    sid = "__console_sub_0"
  }
}

resource "aws_sns_topic_policy" "default" {
  count  = var.create_sns_sqs ? length(var.list_of_sns_names) : 0
  arn    = aws_sns_topic.course1-sns-topic[floor(count.index / 2)].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[count.index].json
}

## SQS
resource "aws_sqs_queue" "course1-sqs-queues" {
  count                      = var.create_sns_sqs ? length(var.list_of_queue_names) : 0
  name                       = "${var.list_of_queue_names[count.index]}${var.env_identifier}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30

  tags = {
    "Name" = "${var.list_of_queue_names[count.index]}${var.env_identifier}"
  }
}

resource "aws_sqs_queue_policy" "course1-sqs-queues-policy" {
  count     = var.create_sns_sqs ? length(var.list_of_queue_names) : 0
  queue_url = aws_sqs_queue.course1-sqs-queues[count.index].id

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.course1-sqs-queues[count.index].arn}"
    },
    {
      "Sid": "__sender_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:${var.sns_sqs_iam}"
      },
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.course1-sqs-queues[count.index].arn}"
    },
    {
      "Sid": "__receiver_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:${var.sns_sqs_iam}"
      },
      "Action": [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage"
      ],
      "Resource": "${aws_sqs_queue.course1-sqs-queues[count.index].arn}"
    },
    {
      "Sid": "${aws_sns_topic.course1-sns-topic[floor(count.index / 2)].arn}",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.course1-sqs-queues[count.index].arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${aws_sns_topic.course1-sns-topic[floor(count.index / 2)].arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "course1-email-subscription" {
  count     = var.create_sns_sqs ? length(var.list_of_queue_names) : 0
  topic_arn = aws_sns_topic.course1-sns-topic[floor(count.index / 2)].arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.course1-sqs-queues[count.index].arn
  filter_policy = <<EOF
{
  "channel": [
    "${element(
  split("-", var.list_of_queue_names[count.index]),
  length(split("-", var.list_of_queue_names[count.index])) - 1
)}"
  ]
}
EOF
}
