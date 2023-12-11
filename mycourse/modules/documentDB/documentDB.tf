resource "aws_docdb_cluster" "documentDB_cluster" {

  cluster_identifier              = format("%s-%s-course1-documentdb-cluster", var.primary_name,var.environment)
  master_username                 = var.db_username
  master_password                 = random_string.documentDB_password.result
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  skip_final_snapshot             = var.db_final_snapshot_identifier == "" ? true : false
  final_snapshot_identifier       = var.db_final_snapshot_identifier == "" ? null : var.db_final_snapshot_identifier
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  port                            = var.db_port
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = aws_docdb_subnet_group.documentDB_subnet_group.id
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.documentDB_parameter_group.id
  engine                          = var.engine
  engine_version                  = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags = {
    "Name" = "${var.primary_name}-${var.environment}-course1-documentDB-cluster"
  }
}  

resource "aws_docdb_cluster_instance" "documentDB_instance" {
  identifier                 = format("%s-%s-course1-documentdb-instance", var.primary_name, var.environment)
  cluster_identifier         = aws_docdb_cluster.documentDB_cluster.id
  apply_immediately          = var.apply_immediately
  instance_class             = var.instance_class
  engine                     = var.engine
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  tags                       = {
    "Name" = "${var.primary_name}-${var.environment}-course1-documentDB-instance"
  }
}

resource "aws_docdb_subnet_group" "documentDB_subnet_group" {
  name        = format("%s-%s-course1-documentdb-subnet-group", var.primary_name, var.environment)
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.subnet_ids_list
  tags        = {
    "Name" = "${var.primary_name}-${var.environment}-course1-documentDB-subnet-group"
  }
}

resource "aws_docdb_cluster_parameter_group" "documentDB_parameter_group" {
  name        = format("%s-%s-course1-documentdb-parameter-group", var.primary_name, var.environment)
  family      = var.cluster_family
  description = "docdb cluster parameter group"

  parameter {
      name  = "tls"
      value = "disabled"
  }
  parameter {
      apply_method = "immediate"
      name         = "profiler"
      value        = "enabled"
  }

  tags    = {
    "Name" = "${var.primary_name}-${var.environment}-course1-documentDB-parameter-group"
  }
}


resource "random_string" "documentDB_password" {
  length  = 32
  special = false
}

output "documentDB_password" {
  sensitive   = false
  value       = random_string.documentDB_password.result
  description = "The master password for DocumentDB"
}
