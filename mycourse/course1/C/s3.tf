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
    "Id": "AWSConsole-AccessLogs-Policy",
    "Statement": [
        {
            "Sid": "AWSConsoleStmt",
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
