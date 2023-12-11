data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_kms_key" "tf_backend" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = {
    Name = "${var.tf_backend_bucket_name}-key"
  }
}

resource "aws_s3_bucket" "tf_backend" {
  bucket = var.tf_backend_bucket_name
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.tf_backend.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  /*logging {
    target_bucket = var.tf_logging_bucket
    target_prefix = var.tf_logging_bucket_prefix
  }
  */
  tags = {
    Name = var.tf_backend_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "tf_backend" {
  bucket = aws_s3_bucket.tf_backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_backend" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tf_backend.arn
  }
  tags = {
    Name = var.dynamodb_table_name
  }
}
