

module "aurora" {
  source                   = "../../../../course1/modules/aurora_encryption"
  primary_name             = var.primary_name
  environment              = var.environment
  enable_aurora            = "true"
  db_instance_count        = 1
  service                  = var.service
  subnet_prefix            = "db-course1-subnets"
  rds_security_groups_list = [aws_security_group.rds-sg.id]
  subnet_ids_list          = data.aws_subnet_ids.private_db.ids
  db_instance_class        = var.db_instance_class
  db_engine_version        = "14.3"
  db_family                = var.db_family
  database_name            = var.database_name
  snapshot_identifier      = var.snapshot_identifier
  kms_key_id               = var.kms_key_id 
  storage_encrypted        = var.storage_encrypted
}

output "master_password_rds" {
  sensitive   = true
  value       = module.aurora.master_password
  description = "The master password for  RDS server"
}

resource "aws_security_group" "rds-sg" {
  name   = "${var.app_name}-${var.environment}-rds"
  vpc_id = var.vpc_id
  tags = {
    "Name" = "${var.app_name}-${var.environment}-rds"
  }
}

resource "aws_security_group_rule" "rds-allow-ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
  security_group_id        = aws_security_group.rds-sg.id
  description              = "${var.environment} ECS Container Instances"
}


resource "aws_security_group_rule" "rds-allow-jumpbox" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [var.jumpbox_cidr]
  security_group_id = aws_security_group.rds-sg.id
  description       = "${var.environment} Jumpbox"
}

resource "aws_security_group_rule" "rds-allow-ecs-subnets" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.list_services_subnet_cidrs
  security_group_id = aws_security_group.rds-sg.id
  description       = "${var.environment} Services Subnets"
}

resource "aws_security_group_rule" "rds-allow-strongdm" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id = ""
  security_group_id = aws_security_group.rds-sg.id
  description       = "SG attached to Fargate ECS for strongdm inaccount in SIN for course1"
}
