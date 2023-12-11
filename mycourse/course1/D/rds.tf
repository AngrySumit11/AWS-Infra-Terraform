##################################### course1 DB #######################################
data "aws_subnet_ids" "private_db" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.private_subnets]
  }
  filter {
    name   = "tag:Env"
    values = [var.environment_common]
  }
  filter {
    name   = "tag:Category"
    values = ["db"]
  }
}

# module "rds-course1" {
#   count                    = var.enable_course1_rds ? 1 : 0
#   source                   = "../../modules/rds"
#   primary_name             = var.primary_name
#   environment              = var.environment
#   service                  = "course1"
#   subnet_prefix            = "db-course1-subnets"
#   enable_extra_rds         = true
#   rds_security_groups_list = [module.course1.postgresql-security-group]
#   subnet_ids_list          = data.aws_subnet_ids.private_db.ids
#   db_instance_class        = var.db_instance_class_api
#   db_engine_version        = "11.12"
#   tags                     = var.common_tags
# }

# output "master_password_extra_rds_course1" {
#   sensitive   = true
#   value       = module.rds-course1.*.master_password
#   description = "The master password for extra course1 RDS server"
# }
####################################################################################

module "rds" {
  source                   = "../../modules/rds"
  primary_name             = var.primary_name
  environment              = var.environment
  service                  = "course1-voting"
  enable_extra_rds         = true
  rds_security_groups_list = [module.course1.postgresql-security-group]
  subnet_ids_list          = data.aws_subnet_ids.private_services.ids
  db_instance_class        = var.db_instance_class_api
  db_engine_version        = "11.13"
  tags                     = var.common_tags
}

output "master_password_extra_rds" {
  sensitive   = true
  value       = module.rds.master_password
  description = "The master password for extra RDS server"
}

resource "aws_security_group_rule" "rds-allow-eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ext-svc-internal.id
  security_group_id        = module.course1.postgresql-security-group
  description              = "${var.environment} EKS Worker Nodes"
}

resource "aws_security_group_rule" "rds-allow-eks-1" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_primary_security_group_id
  security_group_id        = module.course1.postgresql-security-group
  description              = "${var.environment} EKS Master Nodes"
}

resource "aws_security_group_rule" "rds-allow-jumpbox" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.jumpbox.jumpbox-sg-id
  security_group_id        = module.course1.postgresql-security-group
  description              = "${var.environment} Jumpbox"
}

resource "aws_security_group_rule" "rds-allow-strongdm-ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.ecs_strongdm_sg_id
  security_group_id        = module.course1.postgresql-security-group
  description              = "SG attached to Fargate ECS for strongdm in SC-Prod account in SIN for course1"
}

####### Redis security group
resource "aws_security_group_rule" "redis-allow-eks" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ext-svc-internal.id
  security_group_id        = module.course1.redis-security-group
  description              = "${var.environment} EKS Worker Nodes"
}

resource "aws_security_group_rule" "redis-allow-eks-1" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_primary_security_group_id
  security_group_id        = module.course1.redis-security-group
  description              = "${var.environment} EKS Master Nodes"
}

resource "aws_security_group_rule" "redis-allow-jumpbox" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.jumpbox.jumpbox-sg-id
  security_group_id        = module.course1.redis-security-group
  description              = "${var.environment} Jumpbox"
}


################## Encrypted and Upgraded Dev course1 DB ##########

module "course1_rds" {
  source                   = "../../modules/rds_encryption"
  primary_name             = var.primary_name
  environment              = var.environment
  service                  = var.service
  snapshot_identifier      = var.course1_snapshot_identifier
  storage_encrypted        = var.encryption_at_rest
  kms_key_id               = var.kms_key_id  
  enable_extra_rds         = true
  rds_security_groups_list = [aws_security_group.rds-sg.id] 
  db_family                = var.db_family
  subnet_ids_list          = data.aws_subnet_ids.private_services.ids
  db_instance_class        = var.db_instance_class_api
  db_engine_version        = "14.7"
  tags                     = var.common_tags
}


resource "aws_security_group" "rds-sg" {
  name   = format("%s-%s-%s-sg", var.primary_name, var.environment, var.service)
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    "Name" = format("%s-%s-%s-sg", var.primary_name, var.environment, var.service)
  }
}


resource "aws_security_group_rule" "course1-rds-allow-eks-dev" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = ""
  security_group_id        = aws_security_group.rds-sg.id
  description              = "Dev EKS Worker Nodes"
}

