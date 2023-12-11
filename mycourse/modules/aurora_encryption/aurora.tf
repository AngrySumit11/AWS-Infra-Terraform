######### Upgraded and encrypted db ################

resource "aws_rds_cluster" "rds_cluster_encryption" {
  count = var.enable_aurora && var.db_instance_count > 0 ? 1 : 0

  cluster_identifier = format("%s-%s-postgresql-db", var.service, var.environment)
  engine             = "aurora-postgresql"
  engine_version     = var.db_engine_version
  engine_mode        = var.db_engine_mode
  database_name      = var.database_name
  master_username    = var.db_username
  master_password    = random_string.master_password.result

  backup_retention_period         = var.db_backup_retention_period
  db_subnet_group_name            = var.environment == "prod" || var.environment == "dev" || var.environment == "test" ? aws_db_subnet_group.db_subnet_group.id : "db-subnets-${var.environment}-encryption"
  db_cluster_parameter_group_name = format("%s-%s-cluster-encryption", var.service, var.environment)
  skip_final_snapshot             = var.db_final_snapshot_identifier == "" ? true : false
  final_snapshot_identifier       = var.db_final_snapshot_identifier == "" ? null : var.db_final_snapshot_identifier
  vpc_security_group_ids          = var.rds_security_groups_list

  snapshot_identifier             = var.snapshot_identifier
  kms_key_id                      = var.kms_key_id 
  storage_encrypted               = var.storage_encrypted

  tags = {
    "Name"        = format("%s-%s-postgresql-db", var.service, var.environment),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
  depends_on = [aws_db_parameter_group.db_parameter_group_encryption, aws_db_subnet_group.db_subnet_group]
}

resource "aws_rds_cluster_instance" "rds_cluster_instance_encryption" {
  count = var.enable_aurora ? var.db_instance_count : 0

  identifier                 = format("%s-%s-%s-encryption", var.service, var.environment, count.index)
  cluster_identifier         = aws_rds_cluster.rds_cluster_encryption[0].id
  engine                     = "aurora-postgresql"
  engine_version             = var.db_engine_version
  instance_class             = var.db_instance_class
  auto_minor_version_upgrade = false
  copy_tags_to_snapshot      = true
  db_subnet_group_name       = var.environment == "prod" || var.environment == "dev" || var.environment == "test" ? aws_db_subnet_group.db_subnet_group.id : "db-subnets-${var.environment}-encryption"
  db_parameter_group_name    = format("%s-%s-encryption", var.service, var.environment)

  tags = {
    "Name"        = format("%s-%s-db-instance", var.service, var.environment),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,

  }
  depends_on = [aws_db_parameter_group.db_parameter_group_encryption, aws_db_subnet_group.db_subnet_group]

}

resource "aws_rds_cluster_parameter_group" "rds_cluster_parameter_group_encryption" {
  count = var.enable_aurora && var.db_instance_count > 0 ? 1 : 0

  name        = format("%s-%s-cluster-encryption", var.service, var.environment)
  family      = var.db_parameter_group_family
  description = var.description

  tags = {
    "Name"        = format("%s-%s-cluster-parameter-group", var.service, var.environment),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}


resource "aws_db_parameter_group" "db_parameter_group_encryption" {
  count = var.enable_aurora && var.db_instance_count > 0 ? 1 : 0

  name        = format("%s-%s-encryption", var.service, var.environment)
  family      = var.db_parameter_group_family
  description = var.description

  tags = {
    "Name"        = format("%s-%s-db-parameter-group", var.service, var.environment),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.subnet_prefix}-${var.primary_name}-${var.environment}"
  subnet_ids = var.subnet_ids_list

  tags = {
    "Name" = "${var.subnet_prefix}-${var.environment}-db-subnet-group"
  }
}

resource "random_string" "master_password" {
  length  = 32
  special = false
}

output "master_password" {
  sensitive   = false
  value       = random_string.master_password.result
  description = "The master password for  RDS server"
}
