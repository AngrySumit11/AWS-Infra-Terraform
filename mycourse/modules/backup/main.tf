resource "aws_backup_vault" "backup_vault" {
  name = "${var.primary_name}-${var.environment}-${var.server_name}-backup-vault"
  tags = {
    "Name" = "${var.primary_name}-${var.environment}-${var.server_name}"
  }
}

resource "aws_backup_plan" "backup_plan" {
  name = "${var.primary_name}-${var.environment}-${var.server_name}-backup-plan"
  dynamic "rule" {
    for_each = var.rule
    iterator = x

    content {
      rule_name         = lookup(x.value, "name", null)
      target_vault_name = aws_backup_vault.backup_vault.name
      schedule          = lookup(x.value, "schedule", null)
      start_window      = lookup(x.value, "start_window", null)
      completion_window = lookup(x.value, "completion_window", null)
      lifecycle {
        delete_after = lookup(x.value, "delete_after", null)
      }
    }
  }
  tags = {
    "Name" = "${var.primary_name}-${var.environment}-${var.server_name}"
  }
}

resource "aws_backup_selection" "server-backup-selection" {
  iam_role_arn = var.backup_iam_role_arn
  name         = "${var.primary_name}-${var.environment}-${var.server_name}-backup-selection"
  plan_id      = aws_backup_plan.backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.target_backup_server_tag_key
    value = var.target_backup_server_tag_value
  }
}
