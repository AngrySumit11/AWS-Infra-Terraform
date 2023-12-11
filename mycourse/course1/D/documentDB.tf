
module "documentDB" {
  source                   = "../../modules/documentDB"
  enable_documentDB        = true
  primary_name             = var.primary_name
  environment              = var.environment
  vpc_id                   = var.vpc_id
  subnet_ids_list          = [""]
  storage_encrypted        = true
  kms_key_id               = "arn:aws:kms:ap-southeast-1:accountid:key/"
  snapshot_identifier      = var.snapshot_identifier_documentDB
  instance_class           = "db.t3.medium"
  engine                   = "docdb"
  engine_version           = "3.6.0"
  cluster_family           = "docdb3.6"
  vpc_security_group_ids   = [aws_security_group.documentDB_sg.id]
  tags                     = var.common_tags
}

output "master_password_documentDB" {
  sensitive   = true
  value       = module.documentDB.documentDB_password
  description = "The master password for  RDS server"
}

####### Security Groups ########



resource "aws_security_group" "documentDB_sg" {
  name        = format("%s-%s-course1-documentDB-sg", var.primary_name, var.environment)
  description = "Security Group for DocumentDB cluster"
  vpc_id      = var.vpc_id
  tags = {
    "Name"        = format("%s-%s-course1-documentDB-sg", var.primary_name, var.environment),
    "Environment" = var.environment
  }  
}

resource "aws_security_group_rule" "documentDB-allow-eks-cluster" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = ""
  security_group_id        = aws_security_group.documentDB_sg.id
  description              = "${var.environment} EKS Cluster sg"
}

resource "aws_security_group_rule" "documentDB-allow-eks-worker" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = ""
  security_group_id        = aws_security_group.documentDB_sg.id
  description              = "${var.environment} EKS Worker Nodes sg"
}
