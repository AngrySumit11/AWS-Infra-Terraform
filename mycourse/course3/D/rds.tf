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

module "rds_course1" {
  source                                = "../../modules/rds_encryption"
  primary_name                          = var.primary_name
  environment                           = var.environment
  service                               = "course1-db"
  enable_extra_rds                      = true
  rds_security_groups_list              = [module.course1.postgresql-security-group]
  subnet_ids_list                       = data.aws_subnet_ids.private_db.ids
  db_instance_class                     = var.db_instance_class_api
  add_iam_role_to_db                    = true
  db_iam_feature_name                   = var.db_iam_feature_name
  sqlserver_backup_restore_iam_role_arn = var.sqlserver_backup_restore_iam_role_arn
  db_engine_version                     = "14.2"
  replicate_source_db                   = var.replicate_source_db
  snapshot_identifier                   = var.snapshot_identifier
  kms_key_id                            = var.kms_key_id 
  storage_encrypted                     = var.storage_encrypted   
  tags                                  = var.common_tags
}

output "master_password_extra_rds" {
  sensitive   = true
  value       = module.rds_course1.master_password
  description = "The master password for extra RDS server"
}


################## IAM Role to be assumed by RDS ##################
data "aws_iam_policy_document" "assume-rds" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3-export-role" {
  count              = var.enable_s3_export_role ? 1 : 0
  name               = "${var.primary_name}-${var.environment}-course1-db-to-s3-export"
  assume_role_policy = data.aws_iam_policy_document.assume-rds.json
}

resource "aws_iam_role_policy" "sqldb-backup-restore-policy" {
  count = var.enable_s3_export_role ? 1 : 0
  name  = "S3ExportPolicyFromRDS"
  role  = aws_iam_role.s3-export-role[0].id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Sid : "s3import",
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource : [
          "arn:aws:s3:::course1-${var.environment}-course1-staging",
          "arn:aws:s3:::course1-${var.environment}-course1-staging/*",
          "arn:aws:s3:::course1-${var.environment}-course1-staging",
          "arn:aws:s3:::course1-${var.environment}-course1-staging/*"
        ]
      }
    ]
  })
}
########################################################################

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


#########################################
resource "aws_security_group_rule" "rds-allow-strongdm-ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.ecs_strongdm_sg_id
  security_group_id        = module.course1.postgresql-security-group
  description              = "SG attached to Fargate ECS for strongdm in SC-Prod account in SIN for course1"
}

resource "aws_security_group_rule" "rds-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.course1.postgresql-security-group
}

resource "aws_security_group_rule" "rds-allow-eks-sc-course1" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.course1_services_subnet_cidr_list
  security_group_id = module.course1.postgresql-security-group
  description       = "sc-course1 EKS Worker Nodes"
}


######### Upgraded and encrypted lab db ################
resource "aws_db_instance" "course1_encryption" {
  count = var.enable_extra_rds ? 1 : 0

  identifier = format("%s-%s-course1-encryption", var.primary_name, var.environment)

  engine                = var.db_engine
  engine_version        = var.db_engine_version_lab
  instance_class        = var.db_instance_class_api_course1
  allocated_storage     = var.db_storage_size
  max_allocated_storage = var.max_autoscaled_storage
  storage_type          = "gp2"
  deletion_protection   = "false"
  replicate_source_db   = ""
  auto_minor_version_upgrade          = "false"
  backup_retention_period             = var.replicate_source_db == "" ? 7 : 0
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group_encryption[count.index].id
  multi_az                            = "false"
  parameter_group_name                = format("%s-%s-course1-encryption", var.primary_name, var.environment)
  option_group_name                   = var.enable_option_group ? aws_db_option_group.db_option_group_encryption[0].id : ""
  skip_final_snapshot                 = var.db_final_snapshot_identifier == "" ? true : false
  final_snapshot_identifier           = var.db_final_snapshot_identifier == "" ? null : var.db_final_snapshot_identifier
  #snapshot_identifier                 = "course1-prod-course1-09-17-2022-v14-encrypted"
  copy_tags_to_snapshot               = var.replicate_source_db == "" ? true : false
  kms_key_id                          = ""
  storage_encrypted                   = var.storage_encrypted
  customer_owned_ip_enabled           = "false" 
  iam_database_authentication_enabled = "false" 
  iops                                = 0
  security_group_names                = []
  license_model                   = var.license_model
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled    = var.performance_insights_enabled  

  username = var.replicate_source_db == "" ? "root" : ""
  password = var.replicate_source_db == "" ? random_string.master_password.result : ""

  vpc_security_group_ids = [module.course1.postgresql-security-group]

  tags = {
    "Name"        = format("%s-%s-course1-encryption", var.primary_name, var.environment),
    "Environment" = var.environment,
    "Description" = "course1 API Gateway",
    "Service"     = "course1"
  }
  depends_on = [aws_db_parameter_group.course1_encryption, aws_db_subnet_group.db_subnet_group_encryption]
}

resource "aws_db_parameter_group" "course1_encryption" {
  count = var.db_instance_count > 0 ? 1 : 0

  name        = format("%s-%s-course1-encryption", var.primary_name, var.environment)
  family      = "postgres14"
  description = "course1 API Gateway"

  tags = {
    "Name"        = format("%s-%s-course1-encryption", var.primary_name, var.environment),
    "Environment" = var.environment,
    "Description" = "course1 API Gateway",
    "Service"     = "course1"
  }
}

resource "aws_db_subnet_group" "db_subnet_group_encryption" {
  count      = 1
  name       = "course1-${var.primary_name}-${var.environment}-encryption"
  subnet_ids = data.aws_subnet_ids.private_db.ids

  tags = {
    "Name" = "course1-${var.environment}-encryption"
  }
}

resource "aws_db_option_group" "db_option_group_encryption" {
  count                = var.enable_option_group ? 1 : 0
  name                 = "${var.option_prefix}-${var.primary_name}-${var.environment}-encryption"
  engine_name          = "postgres"
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

output "master_password_course1_rds" {
  sensitive   = false
  value       = random_string.master_password.result
  description = "The master password for Hub RDS server"
}
