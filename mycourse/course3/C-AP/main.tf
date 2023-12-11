provider "aws" {
  region  = "ap-southeast-1"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_version = "~> 0.14.4"
  backend "s3" {
    bucket         = "course1-course1-terraform-backend"
    key            = "course1—non-prod/shared-apse1/terraform.tfstate"
    region         = "us-west-2"
    profile        = "course1-prod"
    dynamodb_table = "terraform-lock"
    encrypt        = true

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38.0"
    }
  }
}

resource "aws_key_pair" "default-keypair" {
  key_name   = "default-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiIPZo1VI4kUpzU4Mx/l1B40lXwQenxXLBUIO/WPe5y5DoyD6FYQBnkc1SBJfn9WFCdmyIlcyUw7NpWBa7zr7/WFBE5RvIYsVXDeIL1O6lnIut9AZqzr5LdbYIECDfmqG2ERB3Uh47DZ3v5ja82Auwz7TpcvUNTkCUXAI9Z406rHkgFj+V1cplt+5yplHYjYVEI4DWasQLg815+vlyV1UAmwKHP3OfgqUmgLCXG0t4PxNw9c8FhxfAkADG9uSSjJsM93RLNQOtl3XXaBlw/afhQ7NFeRpOWfyDQ32dP3fxlhS8cMYymOzyhG/3/OBrBZfvGhvWgXkrG7dKNHnZdA7x"
  tags = {
    "Name" = "default-keypair"
  }
}

################ SES ##################################################################################################
# resource "aws_ses_domain_identity" "aws-ses-domain" {
#   domain = var.domain_name
# }

# resource "aws_ses_domain_dkim" "aws-ses-dkim" {
#   domain = aws_ses_domain_identity.aws-ses-domain.domain
# }

# resource "aws_route53_record" "amazonses_dkim_records" {
#   count   = 3
#   zone_id = var.zone_id
#   name    = "${element(aws_ses_domain_dkim.aws-ses-dkim.dkim_tokens, count.index)}._domainkey"
#   type    = "CNAME"
#   ttl     = "60"
#   records = ["${element(aws_ses_domain_dkim.aws-ses-dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
# }

# resource "aws_route53_record" "amazonses_verification_record" {
#   zone_id = var.zone_id
#   name    = "_amazonses.${var.domain_name}"
#   type    = "TXT"
#   ttl     = "60"
#   records = [aws_ses_domain_identity.aws-ses-domain.verification_token]
# }

# resource "aws_ses_receipt_rule_set" "main" {
#   rule_set_name = "default-ruleset"
# }

# resource "aws_ses_active_receipt_rule_set" "main" {
#   rule_set_name = "default-ruleset"
#   depends_on = [aws_ses_receipt_rule_set.main]
# }

# resource "aws_ses_receipt_rule" "ses-receipt-rule" {
#   name          = "${var.common_ses_name}-${var.environment}"
#   rule_set_name = "default-ruleset"
#   recipients    = ["${var.common_ses_name}-${var.environment}@${var.domain_name}"]
#   enabled       = true
#   scan_enabled  = true

#   s3_action {
#     bucket_name = "${var.primary_name}-${var.environment}-${var.common_ses_name}"
#     position    = 1
#     topic_arn   = aws_sns_topic.ses-rule-topic.arn
#   }
#   depends_on = [aws_s3_bucket_policy.s3-bucket-policy-data]
# }

################ SNS ##################################################################################################
# resource "aws_sns_topic" "ses-rule-topic" {
#   name            = "${var.primary_name}-${var.environment}-${var.common_ses_name}"
#   delivery_policy = <<EOF
# {
#   "http": {
#     "defaultHealthyRetryPolicy": {
#       "minDelayTarget": 20,
#       "maxDelayTarget": 20,
#       "numRetries": 3,
#       "numMaxDelayRetries": 0,
#       "numNoDelayRetries": 0,
#       "numMinDelayRetries": 0,
#       "backoffFunction": "linear"
#     },
#     "disableSubscriptionOverrides": false
#   }
# }
# EOF
#   tags = {
#     "Name"      = "${var.primary_name}-${var.environment}-${var.common_ses_name}"
#   }
# }

# resource "aws_sns_topic_policy" "ses-rule-topic-policy" {
#   arn = aws_sns_topic.ses-rule-topic.arn
#   policy = data.aws_iam_policy_document.ses-rule-topic-policy-data.json
# }

# data "aws_iam_policy_document" "ses-rule-topic-policy-data" {
#   policy_id = "__default_policy_ID"

#   statement {
#     actions = [
#       "SNS:GetTopicAttributes",
#       "SNS:SetTopicAttributes",
#       "SNS:AddPermission",
#       "SNS:RemovePermission",
#       "SNS:DeleteTopic",
#       "SNS:Subscribe",
#       "SNS:ListSubscriptionsByTopic",
#       "SNS:Publish",
#       "SNS:Receive"
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceOwner"
#       values = [var.aws_account_id]
#     }

#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     resources = [
#       aws_sns_topic.ses-rule-topic.arn,
#     ]

#     sid = "__default_statement_ID"
#   }
# }

################ S3 ###################################################################################################
# resource "aws_s3_bucket_policy" "s3-bucket-policy-data" {
#   count = length(var.s3_bucket_names)
#   bucket = "${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid       = "AllowSESPutAction"
#         Effect    = "Allow"
#         Principal = {
#           Service = "ses.amazonaws.com"
#         }
#         Action    = ["s3:PutObject"]
#         Resource = [
#           "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}",
#           "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}/*"
#         ]
#         Condition = {
#           StringEquals = {
#             "aws:Referer" = var.aws_account_id
#           }
#         }
#       },
#       {
#         Sid = "AllowPolicy",
#         Effect = "Allow",
#         Principal = {
#           "AWS": [
#             "arn:aws:iam::${var.aws_account_id}:root",
#             "arn:aws:iam::${var.aws_account_id}:role/terraform",
#             "arn:aws:iam::${var.aws_account_id}:role/admin-full",
#             aws_iam_role.efront_snowflake_role.arn,
#             module.efront.efront-iam-role[0],
#           ]
#         },
#         Action = ["s3:*"],
#         Resource = [
#           "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}",
#           "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}/*"
#         ]
#       },
#       {
#         Sid = "DenyPolicy",
#         Effect = "Deny",
#         Principal = "*",
#         Action = ["s3:*"],
#         Resource = [
#           "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}",
#           "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}/*"
#         ],
#         "Condition": {
#           "StringNotLike": {
#               "aws:userId": var.s3_allow_userIds,
#               "aws:Referer": var.aws_account_id,
#               "AWS:SourceAccount": var.aws_account_id,
#               "AWS:SourceArn": "arn:aws:ses:us-west-2:${var.aws_account_id}:receipt-rule-set/*"
#           }
#         }
#       }
#     ]
#   })
# }
# 
# resource "aws_iam_openid_connect_provider" "GithubOidc" {
#   url = join("//",[ "https:", var.gh_oidc_url])
#   client_id_list =  var.client_id_list
#   thumbprint_list = var.thumbprint_list
# }
