data "aws_vpc" "vpc" {
  state = "available"
  tags = {
    "Name" = var.vpc
  }
}

# module "efront" {
#   source = "../../modules/efront"

#   vpc                       = var.vpc
#   primary_name              = var.primary_name
#   environment               = var.environment
#   ec2_ami_id_windows        = "ami-049b3075edbaee4e7"
#   ec2_key_pair	            = "default-keypair"
#   server_name               = "efront"
#   instance_type_windows     = var.instance_type_windows
#   windows_count             = 1
#   ebs_optimized_windows     = var.ebs_optimized_windows
#   source_sg_for_rdp         = var.source_sg_for_rdp_ssh
#   linux_count               = 1
#   ec2_ami_id_linux          = var.ec2_ami_id_linux
#   instance_type_linux       = var.instance_type_linux
#   list_of_cidr_for_ssh      = var.list_of_cidr_for_ssh
#   source_sg_for_ssh         = var.source_sg_for_rdp_ssh
#   s3_bucket_names           = var.s3_bucket_names
#   create_iam_role           = true
#   common_tags               = var.common_tags
# }

# resource "aws_iam_role" "efront_snowflake_role" {
#   name  = "snowflake_role"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::652630300277:user/o2sc-s-p2st0171"
#       },
#       "Action": "sts:AssumeRole",
#       "Condition": {
#         "StringEquals": {
#           "sts:ExternalId": "DZA79633_SFCRole=2_zwSNKJOkLQYuOzQVhm36LISr9pI="
#         }
#       }
#     }
#   ]
# }
# EOF
# }

# data "aws_iam_policy_document" "eks-s3-policy-document" {
#   dynamic "statement" {
#     for_each = range(length(var.s3_bucket_names))
#     content {
#       sid     = "EKSS3Policy${statement.value}"
#       actions = [
#         "s3:GetObject",
#         "s3:GetObjectVersion",
#         "s3:ListBucket",
#         "s3:PutObject",
#         "s3:DeleteObject",
#         "s3:DeleteObjectVersion"
#       ]
#       effect  = "Allow"
#       resources = [
#         "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[statement.value]}/*",
#         "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[statement.value]}"
#       ]
#     }
#   }
# }

# resource "aws_iam_role_policy" "eks-s3-policy" {
#   name       = "eFront-S3-Policy"
#   role       = aws_iam_role.efront_snowflake_role.name
#   policy     = data.aws_iam_policy_document.eks-s3-policy-document.json
#   depends_on = [aws_iam_role.efront_snowflake_role]
# }

# resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforAWSCodeDeploy-attachment" {
#   role       = aws_iam_role.efront_snowflake_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
# }

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
