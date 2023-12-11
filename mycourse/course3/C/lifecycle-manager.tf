/*
module "dlm-efront" {
  source = "../../modules/lifecycle-manager"

  primary_name = var.primary_name
  environment  = var.environment
  server_name  = var.server_name
}

resource "aws_dlm_lifecycle_policy" "dlm_lifecycle_policy" {
  description        = "DLM lifecycle policy"
  execution_role_arn = module.dlm-efront.dlm-iam-role
  state              = "ENABLED"
  policy_details {
    resource_types = ["VOLUME"]
    schedule {
      name = "Two weeks of daily snapshots for ${var.primary_name}-${var.environment}-${var.server_name}-linux VM"
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["15:30"]
      }
      retain_rule {
        count = 14
      }
      tags_to_add = {
        SnapshotCreator = "DLM"
      }
      copy_tags = false
    }
    target_tags = {
      Name = "${var.primary_name}-${var.environment}-${var.server_name}-linux"
    }
  }
  tags = {
    Name = "${var.primary_name}-${var.environment}-${var.server_name}-linux-dlm"
  }
}
*/