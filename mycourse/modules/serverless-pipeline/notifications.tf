
resource "aws_codestarnotifications_notification_rule" "slack_notify" {
  detail_type = "BASIC"
  event_type_ids = ["codepipeline-pipeline-pipeline-execution-failed",
  "codepipeline-pipeline-pipeline-execution-succeeded"]

  name     = "${var.project_prefix}-${var.environment}-notify-cp-${var.service_name}"
  resource = aws_codepipeline.codepipeline.arn

  target {
    address = var.notify_sns_arn
  }
  tags = {
    Name    = "${var.project_prefix}-${var.environment}-notify-cp-${var.service_name}"
  }
}


