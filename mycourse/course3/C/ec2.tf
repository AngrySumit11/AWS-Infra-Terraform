data "aws_vpc" "vpc" {
  state = "available"
  tags = {
    "Name" = var.vpc
  }
}

data "aws_security_group" "dev_jumpbox_sg" {
  vpc_id  = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["course1-jumpbox-dev"]
  }
  filter {
    name   = "tag:sc_env"
    values = ["dev"]
  }
  filter {
    name   = "tag:sc_app"
    values = ["apihub"]
  }
  
}

module "course1" {
  source = "../../modules/course1"

  vpc                       = var.vpc
  primary_name              = var.primary_name
  environment               = var.environment
  ec2_ami_id_windows        = "ami-049b3075edbaee4e7"
  ec2_key_pair	            = "default-keypair"
  server_name               = "course1"
  instance_type_windows     = var.instance_type_windows
  windows_count             = 1
  ebs_optimized_windows     = var.ebs_optimized_windows
  source_sg_for_rdp         = var.source_sg_for_rdp_ssh
  linux_count               = 0
  ec2_ami_id_linux          = var.ec2_ami_id_linux
  instance_type_linux       = var.instance_type_linux
  sg_for_ssh                = data.aws_security_group.dev_jumpbox_sg.id
  source_sg_for_ssh         = var.source_sg_for_rdp_ssh
  s3_bucket_names           = var.s3_bucket_names
  create_iam_role           = true
  common_tags               = var.common_tags
}

resource "aws_iam_role" "course1_snowflake_role" {
  name               = "snowflake_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ""
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "DZA79633_SFCRole=2_We0PmTBhfn2GxkZpeZrT/xSaXmw="
        }
      }
    }
  ]
}
EOF
}


data "aws_iam_policy_document" "eks-s3-policy-document" {
  dynamic "statement" {
    for_each = range(length(var.s3_bucket_names))
    content {
      sid = "EKSS3Policy${statement.value}"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ]
      effect = "Allow"
      resources = [
        "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[statement.value]}/*",
        "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[statement.value]}"
      ]
    }
  }
}

resource "aws_iam_role_policy" "snowflake-course1-S3-Policy" {
  name       = "snowflake-course1-S3-Policy"
  role       = aws_iam_role.course1_snowflake_role.name
  policy     = data.aws_iam_policy_document.eks-s3-policy-document.json
  depends_on = [aws_iam_role.course1_snowflake_role]
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforAWSCodeDeploy-attachment" {
  role       = aws_iam_role.course1_snowflake_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

# module "leanix-server" {
#   source = "../../modules/ec2"
#   ec2_ami_id = "ami-01773ce53581acf22"
#   environment = var.environment
#   primary_name = var.primary_name
#   server_name = "leanix"
#   instance_type = "t3.medium"
#   name_tag      = "course1-dev-apps-services-usw2-az2"
#   vpc = var.vpc
#   ec2_key_pair = "default-keypair"
#   list_of_cidr_for_ssh =  ["10.219.0.0/16"]
#   category = "services"
#   iam_instance_profile = "course1-dev-apps-leanix-ingestion-role"
#   volume_size = 30
#   tags = var.common_tags
#   list_of_iam_policy_arn = var.list_of_iam_policy_arn
# }

##################################################   EC2 for course1 non-prod performance testing ########################
/*
module "course1_nonprod_performance_testing" {
  source = "../../modules/ec2"
  ec2_ami_id = "ami-59694f21"
  environment = var.environment
  primary_name = var.primary_name
  server_name = "performance-testing"
  instance_type = "m5.xlarge"
  name_tag      = "course1-dev-apps-services-usw2-az2"
  vpc = "course1-non-prod"
  ec2_key_pair = "default-keypair"
  list_of_cidr_for_ssh =  ["10.219.0.0/16"]
  category = "services"
  iam_instance_profile = ""
  volume_size = 30
  tags = var.common_tags
}

resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  source_security_group_id = var.ingress_rules[count.index].source_security_group_id
  description       = var.ingress_rules[count.index].description
  security_group_id = module.course1_nonprod_performance_testing.jumpbox-sg-id
}
*/