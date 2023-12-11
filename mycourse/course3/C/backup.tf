module "efront-linux-backup" {
  source = "../../modules/backup"

  primary_name    = var.primary_name
  environment     = var.environment
  server_name     = var.server_name
  aws_account_id  = var.aws_account_id
  backup_iam_role_arn = var.backup_iam_role_arn
  rule = [
    {
      name              = "weekly_backup_${var.primary_name}-${var.environment}-${var.server_name}-linux"
      schedule          = "cron(0 8 ? * SAT *)"
      start_window      = "60"
      completion_window = "300"
      delete_after      = "15"
    }
  ]
  target_backup_server_tag_key   = "Name"
  target_backup_server_tag_value = "${var.primary_name}-${var.environment}-${var.server_name}-linux"
}
