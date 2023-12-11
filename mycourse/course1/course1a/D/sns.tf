resource "aws_sns_topic" "codepipeline_status" {
  name            = "${var.app_name}-${var.environment}-codepipeline-status"
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
    "Name" = "${var.app_name}-${var.environment}-codepipeline-status"
  }
}