resource "aws_s3_bucket" "s3-bucket" {
  count  = length(var.s3_bucket_names)
  bucket = "${var.primary_short_name}-${var.s3_bucket_names[count.index]}${var.env_identifier}"
  acl    = "private"
  lifecycle_rule {
    id      = "${var.primary_short_name}-${var.s3_bucket_names[count.index]}${var.env_identifier}-bucket-lifecycle-rule"
    enabled = true

    expiration {
      days = 15
    }
  }  
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

resource "aws_s3_bucket" "s3_bucket_hub" {
  count  = length(var.s3_bucket_names_hub)
  bucket = "${var.primary_short_name}-${var.s3_bucket_names_hub[count.index]}${var.env_identifier}"
  acl    = "private"
  tags = {
    "Name"        = "${var.primary_short_name}-${var.s3_bucket_names_hub[count.index]}${var.env_identifier}",
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

resource "aws_s3_bucket_public_access_block" "block-s3-public-access-hub" {
  count                   = length(var.s3_bucket_names_hub)
  bucket                  = aws_s3_bucket.s3_bucket_hub[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
