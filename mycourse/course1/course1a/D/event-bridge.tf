resource "aws_cloudwatch_event_rule" "mediaconvert" {
  name        = "${var.service}-mediaconvert-${var.environment}-jobstatus-rule"
  description = "Event bridge Rule for mediaconvert job status"

  event_pattern = <<EOF
{
  "source": ["aws.mediaconvert"],
  "detail-type": ["MediaConvert Job State Change"],
  "detail": {
    "status": ["ERROR", "COMPLETE"]
  }
}
EOF
  tags = {
    "Name" = "${var.service}-mediaconvert-${var.environment}-jobstatus-rule"
  }
}

resource "aws_cloudwatch_event_target" "sqs" {
  rule      = aws_cloudwatch_event_rule.mediaconvert.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.course1-sqs-mediaconvert.arn
}