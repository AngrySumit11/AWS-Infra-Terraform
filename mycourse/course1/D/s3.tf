resource "aws_s3_bucket" "s3-bucket" {
  count  = length(var.s3_bucket_names)
  bucket = "${var.primary_short_name}-${var.s3_bucket_names[count.index]}${var.env_identifier}"
  acl    = "private"
  tags = {
    "Name"        = "${var.primary_short_name}-${var.s3_bucket_names[count.index]}${var.env_identifier}",
    "Environment" = var.environment
  }
  server_side_encryption_configuration {
          rule {
              bucket_key_enabled = false 
              apply_server_side_encryption_by_default {
                  sse_algorithm = "AES256" 
                }
            }
  }
}

resource "aws_s3_bucket_public_access_block" "block-s3-public-access" {
  count                   = length(var.s3_bucket_names)
  bucket                  = aws_s3_bucket.s3-bucket[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

data "aws_iam_policy_document" "eks-s3-policy-document" {
  # Used by Content and PDF Generation api
  dynamic "statement" {
    for_each = range(length(var.s3_bucket_names))
    content {
      sid     = "EKSS3Policy${statement.value}"
      actions = ["s3:*"]
      effect  = "Allow"
      resources = [
        aws_s3_bucket.s3-bucket[statement.value].arn, "${aws_s3_bucket.s3-bucket[statement.value].arn}/*"
      ]
    }
  }
  statement {
    sid     = "EKSS3Policy001"
    actions = ["s3:*"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::${var.ses_rule_bucket_name}", "arn:aws:s3:::${var.ses_rule_bucket_name}/*",
      "arn:aws:s3:::${var.ses_rule_bucket_name_journal}", "arn:aws:s3:::${var.ses_rule_bucket_name_journal}/*"
    ]
  }
}

resource "aws_iam_role_policy" "eks-s3-policy" {
  count      = length(var.api_list_iam_roles)
  name       = "EKS-S3-Policy"
  role       = aws_iam_role.eks_pod_iam_role[0].name
  policy     = data.aws_iam_policy_document.eks-s3-policy-document.json
  depends_on = [aws_iam_role.eks_pod_iam_role]
}

