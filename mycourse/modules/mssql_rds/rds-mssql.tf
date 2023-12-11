resource "aws_db_parameter_group" "rds_mssql_parameter_group" {
  name        = format("%s-%s-parameter-group", var.primary_name, var.environment)
  family      = var.db_family
  description = "AWS MS SQL RDS Parameter Group"

  tags = {
    "Name"        = format("%s-%s-parameter-group", var.primary_name, var.environment),
    "Environment" = var.environment,
    "Description" = "AWS MS SQL RDS Parameter Group"
  }
}

resource "aws_db_subnet_group" "rds_mssql_subnet_group" {
  name        = format("%s-%s-subnet-group", var.primary_name, var.environment)
  description = "The DB Subnet Group."
  subnet_ids  = var.vpc_subnet_ids

  tags = {
    "Name"        = format("%s-%s-subnet-group", var.primary_name, var.environment),
    "Environment" = var.environment,
    "Description" = "AWS MS SQL RDS Subnet Group"
  }
}

resource "aws_db_instance" "mssql_instance" {
  depends_on                = [aws_db_parameter_group.rds_mssql_parameter_group, aws_db_subnet_group.rds_mssql_subnet_group]
  snapshot_identifier       = var.snapshot_identifier
  identifier                = format("%s-%s-rds-mssql", var.primary_name, var.environment)
  allocated_storage         = var.rds_allocated_storage
  license_model             = "license-included"
  storage_type              = "gp2"
  engine                    = var.engine_type
  engine_version            = var.rds_engine_version
  instance_class            = var.rds_instance_class
  multi_az                  = var.rds_multi_az
  #username                  = var.mssql_admin_username
  #password                  = var.mssql_admin_password
  vpc_security_group_ids    = var.rds_security_group_ids
  db_subnet_group_name      = aws_db_subnet_group.rds_mssql_subnet_group.id
  parameter_group_name      = aws_db_parameter_group.rds_mssql_parameter_group.id 
  backup_retention_period   = 7
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.primary_name}-${var.environment}-mssql-final-snapshot"

  tags = {
    "Name"        = format("%s-%s-rds-mssql", var.primary_name, var.environment),
    "Environment" = var.environment,
    "Description" = "AWS MS SQL RDS Instance"
  }  
}