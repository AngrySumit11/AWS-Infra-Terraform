module "mssql_rds" {
  source                    = "../../modules/mssql_rds"
  primary_name              = var.primary_name
  environment               = var.environment
  snapshot_identifier       = var.snapshot_identifier
  db_family                 = var.db_family
  vpc_subnet_ids            = var.vpc_subnet_ids
  vpc_id                    = var.vpc_id
  rds_allocated_storage     = var.rds_allocated_storage
  engine_type               = var.engine_type
  rds_engine_version        = var.rds_engine_version
  rds_instance_class        = var.rds_instance_class            
  rds_security_group_ids    = [aws_security_group.rds_mssql_security_group.id]
  rds_multi_az              = var.rds_multi_az  
  skip_final_snapshot       = var.skip_final_snapshot   
}

resource "aws_security_group" "rds_mssql_security_group" {
  name   = format("%s-%s-security-group", var.primary_name, var.environment)
  description = "AWS MS SQL RDS Security Group"
  vpc_id = var.vpc_id
  tags = {
    "Name"        = format("%s-%s-security-group", var.primary_name, var.environment),
    "Environment" = var.environment,
    "Description" = "AWS MS SQL RDS Security Group"
  }
}

// Identifier of the mssql DB instance.
output "mssql_id" {
  value = aws_db_instance.mssql_instance.id
}

// Address of the mssql DB instance.
output "mssql_address" {
  value = aws_db_instance.mssql_instance.address
}