resource "aws_s3_bucket" "s3-bucket" {
  count  = length(var.s3_bucket_names)
  bucket = "${var.primary_name}-${var.s3_bucket_names[count.index]}-${var.environment}"
  acl    = "private"
  tags = {
    "Name"        = "${var.primary_name}-${var.s3_bucket_names[count.index]}-${var.environment}",
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

resource "aws_s3_bucket" "s3_video_upload" {
  bucket        = "${var.primary_name}-course1-s3-academy-video-upload-${var.environment}"
  acl           = "private"
  force_destroy = false
  cors_rule {
    allowed_headers = ["Authorization", "x-amz-date", "x-amz-content-sha256", "content-type"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
  tags = {
    "Name"        = "${var.primary_name}-course1-s3-academy-video-upload-${var.environment}",
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

resource "aws_s3_bucket_public_access_block" "block-s3-public-access-course1-video-upload" {
  bucket                  = "${var.primary_name}-course1-s3-academy-video-upload-${var.environment}"
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket" "s3_bucket_assets" {
  bucket        = "${var.primary_name}-course1app-assets-${var.environment}"
  acl           = "private"
  force_destroy = false
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
  tags = {
    "Name"        = "${var.primary_name}-course1app-assets-${var.environment}",
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

resource "aws_s3_bucket_public_access_block" "block-s3-public-access-course1app-assets" {
  bucket                  = "${var.primary_name}-course1app-assets-${var.environment}"
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


resource "aws_s3_bucket" "s3_bucket_media" {
  bucket        = "${var.primary_name}-course1-s3-media-${var.environment}"
  acl           = "private"
  force_destroy = false
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = [""]
    expose_headers  = []
    max_age_seconds = 3000
  }
  tags = {
    "Name"        = "${var.primary_name}-course1-s3-media-${var.environment}",
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

resource "aws_s3_bucket_public_access_block" "block-s3-public-access-course1-media" {
  bucket                  = "${var.primary_name}-course1-s3-media-${var.environment}"
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


resource "aws_s3_bucket" "s3_bucket_admin" {
  bucket        = "${var.primary_name}-course1admin-${var.environment}"
  acl           = "private"
  force_destroy = false
  website {
    index_document = "index.html"
  }
  tags = {
    "Name"        = "${var.primary_name}-course1admin-${var.environment}",
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

resource "aws_s3_bucket_public_access_block" "block-s3-public-access-course1admin" {
  bucket                  = "${var.primary_name}-course1admin-${var.environment}"
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}