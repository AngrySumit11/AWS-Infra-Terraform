resource "aws_s3_bucket" "lb_access_logs" {
  count  = 0
  bucket = var.logs_bucket_name
  acl    = "private"

  tags = merge(
    {
      "Name"      = var.logs_bucket_name,
      "Terraform" = true
    }
  )
}

resource "aws_s3_bucket_policy" "lb_access_logs_policy" {
  count  = 0
  bucket = aws_s3_bucket.lb_access_logs[count.index].id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "AWSConsole-AccessLogs-Policy-1611213664395",
    "Statement": [
        {
            "Sid": "AWSConsoleStmt-1611213664395",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.elb_account_id}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.logs_bucket_name}/*/AWSLogs/${var.aws_account_id}/*"
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.logs_bucket_name}/*/AWSLogs/${var.aws_account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.logs_bucket_name}"
        }
    ]
}
POLICY
}

// S3 bucket for storing common objects ( i.e. red-canary shell script )
resource "aws_s3_bucket" "common-configs" {
  bucket = "${var.primary_name}-${var.environment_common}-common-configs"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = "${var.primary_name}-${var.environment_common}-common-configs"
  }
}

resource "aws_s3_bucket_public_access_block" "common_configs" {
  bucket = aws_s3_bucket.common-configs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "helm-charts" {
  bucket = "course1-helm-charts"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = "course1-helm-charts"
  }
}

resource "aws_s3_bucket_public_access_block" "helm-charts" {
  bucket = aws_s3_bucket.helm-charts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}
