resource "aws_db_instance" "course1" {
  count = local.enable_rds ? 1 : 0

  identifier = format("%s-%s-%s", var.primary_name, var.environment, var.service)


  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_storage_size
  storage_type      = "gp2"
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  backup_retention_period   = var.db_backup_retention_period
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group[count.index].id
  multi_az                  = var.db_multi_az
  parameter_group_name      = format("%s-%s-%s", var.primary_name, var.environment, var.service)
  skip_final_snapshot       = var.db_final_snapshot_identifier == "" ? true : false
  final_snapshot_identifier = var.db_final_snapshot_identifier == "" ? null : var.db_final_snapshot_identifier
  snapshot_identifier       = var.snapshot_identifier
  copy_tags_to_snapshot     = true

  username = var.db_username
  password = random_string.master_password.result

  vpc_security_group_ids = [aws_security_group.postgresql.id]

  tags = {
    "Name"        = format("%s-%s-%s", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
  depends_on = [aws_db_parameter_group.course1, aws_security_group.postgresql, aws_db_subnet_group.db_subnet_group]
}

resource "aws_db_parameter_group" "course1" {
  count = var.db_instance_count > 0 ? 1 : 0

  name        = format("%s-%s-%s", var.primary_name, var.environment, var.service)
  family      = var.db_family
  description = var.description

  tags = {
    "Name"        = format("%s-%s-%s", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  count      = 1
  name       = "db-subnets-${var.environment}"
  subnet_ids = data.aws_subnet_ids.private_services.ids

  tags = {
    "Name" = "db-subnets-${var.environment}"
  }
}
