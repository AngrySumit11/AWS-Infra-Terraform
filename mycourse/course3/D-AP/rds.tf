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
  service                               = "db"
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

resource "aws_db_instance_role_association" "db_instance_role_association_encryption" {
   db_instance_identifier = "course1-dev-course1-db-encryption"
   feature_name           = "s3Import"
   role_arn               = ""
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

resource "aws_security_group_rule" "rds-allow-eks-course1" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.course1_services_subnet_cidr_list
  security_group_id = module.course1.postgresql-security-group
  description       = "course1 EKS Worker Nodes"
}
