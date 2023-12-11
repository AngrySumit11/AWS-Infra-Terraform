
######### Upgraded and encrypted db ################
resource "aws_db_instance" "course1_encryption" {
  count = var.enable_extra_rds ? 1 : 0

  identifier = format("%s-%s-%s-encryption", var.primary_name, var.environment, var.service)


  engine                = var.db_engine
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_storage_size
  max_allocated_storage = var.max_autoscaled_storage
  storage_type          = "gp2"
  deletion_protection   = var.deletion_protection
  replicate_source_db   = var.replicate_source_db
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  backup_retention_period         = var.replicate_source_db == "" ? var.db_backup_retention_period : 0
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group_encryption[count.index].id
  multi_az                        = var.db_multi_az
  parameter_group_name            = format("%s-%s-%s-encryption", var.primary_name, var.environment, var.service)
  option_group_name               = var.enable_option_group ? aws_db_option_group.db_option_group_encryption[0].id : ""
  skip_final_snapshot             = var.db_final_snapshot_identifier == "" ? true : false
  final_snapshot_identifier       = var.db_final_snapshot_identifier == "" ? null : var.db_final_snapshot_identifier
  snapshot_identifier             = var.snapshot_identifier
  copy_tags_to_snapshot           = var.replicate_source_db == "" ? true : false
  kms_key_id                      = var.kms_key_id
  storage_encrypted               = var.storage_encrypted
  license_model                   = var.license_model
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled    = var.performance_insights_enabled

  username = var.replicate_source_db == "" ? var.db_username : ""
  password = var.replicate_source_db == "" ? random_string.master_password.result : ""

  vpc_security_group_ids = var.rds_security_groups_list

  tags = {
    "Name"        = format("%s-%s-%s-encryption", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service
  }
  depends_on = [aws_db_parameter_group.course1_encryption, aws_db_subnet_group.db_subnet_group_encryption]
}

resource "aws_db_parameter_group" "course1_encryption" {
  count = var.db_instance_count > 0 ? 1 : 0

  name        = format("%s-%s-%s-encryption", var.primary_name, var.environment, var.service)
  family      = var.db_family
  description = var.description

  tags = {
    "Name"        = format("%s-%s-%s-encryption", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service
  }
}

resource "aws_db_subnet_group" "db_subnet_group_encryption" {
  count      = 1
  name       = "${var.subnet_prefix}-${var.primary_name}-${var.environment}-${var.service}-encryption"
  subnet_ids = var.subnet_ids_list

  tags = {
    "Name" = "${var.subnet_prefix}-${var.environment}-${var.service}-encryption"
  }
}

resource "aws_db_option_group" "db_option_group_encryption" {
  count                = var.enable_option_group ? 1 : 0
  name                 = "${var.option_prefix}-${var.primary_name}-${var.environment}-encryption"
  engine_name          = var.db_engine
  major_engine_version = var.db_options_engine_version

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = var.sqlserver_backup_restore_iam_role_arn
    }
  }
}

resource "aws_db_instance_role_association" "db_instance_role_association_encryption" {
  count                  = var.add_iam_role_to_db ? 1 : 0
  db_instance_identifier = aws_db_instance.course1_encryption[count.index].id
  feature_name           = var.db_iam_feature_name
  role_arn               = var.sqlserver_backup_restore_iam_role_arn
}

resource "random_string" "master_password" {
  length  = 32
  special = false
}

output "master_password" {
  sensitive   = false
  value       = random_string.master_password.result
  description = "The master password for extra RDS server"
}
