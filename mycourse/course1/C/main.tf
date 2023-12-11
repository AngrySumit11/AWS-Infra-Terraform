provider "aws" {
  region  = "ap-southeast-1"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias   = "course1-non-prod-us-west-2"
  region  = "us-west-2"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias   = "course1-non-prod-us-west-2"
  region  = "us-west-2"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias   = "course1-non-prod-us-east-1"
  region  = "us-east-1"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_version = "~> 0.14.4"
  backend "s3" {
    bucket         = "course1-terraform-backend"
    key            = "course1-non-prod/shared/terraform.tfstate"
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
  public_key = ""
  tags = {
    "Name" = "default-keypair"
  }
}

resource "aws_ses_domain_identity" "aws-ses-domain" {
  provider = aws.course1-non-prod-us-west-2
  domain   = var.domain_name
}

resource "aws_ses_domain_dkim" "aws-ses-dkim" {
  provider = aws.course1-non-prod-us-west-2
  domain   = aws_ses_domain_identity.aws-ses-domain.domain
}

resource "aws_route53_record" "amazonses_dkim_records" {
  provider = aws.course1-non-prod-us-west-2

  count   = 3
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.aws-ses-dkim.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "60"
  records = ["${element(aws_ses_domain_dkim.aws-ses-dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# This Route53 record is being managed at course1-non-prod/shared/main.tf config
//resource "aws_route53_record" "amazonses_verification_record" {
//  provider = aws.course1-non-prod-us-west-2
//
//  zone_id = var.zone_id
//  name    = "_amazonses.${var.domain_name}"
//  type    = "TXT"
//  ttl     = "60"
//  records = [aws_ses_domain_identity.aws-ses-domain.verification_token, "bC0jvGJH0J+XP/5QikAk8FhoVFR79CPkn847F7c+Yq4="]
//}

resource "aws_ses_receipt_rule_set" "main" {
  provider      = aws.course1-non-prod-us-west-2
  rule_set_name = "${var.primary_name}-sdcrm-main"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  provider      = aws.course1-non-prod-us-west-2
  rule_set_name = "${var.primary_name}-sdcrm-main"
}



################ S3 ###################################################################################################
resource "aws_s3_bucket" "s3-ses-bucket" {
  count  = length(var.s3_bucket_names)
  bucket = "${var.primary_name}-${var.s3_bucket_names[count.index]}-${var.environment}"
  acl    = "private"
  versioning {
    enabled = false
  }
  tags = {
    "Name"        = "${var.primary_name}-${var.s3_bucket_names[count.index]}-${var.environment}"
    "Environment" = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "block-s3-public-access" {
  count                   = length(var.s3_bucket_names)
  bucket                  = aws_s3_bucket.s3-ses-bucket[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  depends_on              = [aws_s3_bucket.s3-ses-bucket]
}

resource "aws_s3_bucket_policy" "s3-ses-bucket-policy" {
  count  = length(var.s3_bucket_names)
  bucket = aws_s3_bucket.s3-ses-bucket[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICYFORSES"
    Statement = [
      {
        Sid    = "AllowSESPuts"
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action = ["s3:PutObject"]
        Resource = [
          aws_s3_bucket.s3-ses-bucket[count.index].arn,
          "${aws_s3_bucket.s3-ses-bucket[count.index].arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:Referer" = var.aws_account_id
          }
        }
      },
    ]
  })
  depends_on = [aws_s3_bucket.s3-ses-bucket, aws_s3_bucket_public_access_block.block-s3-public-access]
}

resource "aws_iam_openid_connect_provider" "GithubOidc" {
  url             = join("//", ["https:", var.gh_oidc_url])
  client_id_list  = var.client_id_list
  thumbprint_list = var.thumbprint_list
}



resource "aws_key_pair" "course1-non-prod" {
  key_name   = "course1-non-prod-keypair"
  public_key = "="
  tags = {
    "Name" = "course1-non-prod-keypair"
  }

}