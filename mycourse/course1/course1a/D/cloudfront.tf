################### Cloudfront distribution for Assets################

data "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket
}
resource "aws_cloudfront_origin_access_identity" "assets" {
  comment = "OAI for Assests Bucket"
}
resource "aws_cloudfront_response_headers_policy" "assets_security_headers_policy" {
  name = "course1-${var.environment}-Assets-Security-Headers-Policy"
  security_headers_config {
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    strict_transport_security {
      access_control_max_age_sec = "15552000"
      include_subdomains         = true
      override                   = true
    }
  }
}
resource "aws_cloudfront_distribution" "s3_assets_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.assets.bucket_domain_name
    origin_id   = var.assets_bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.assets.cloudfront_access_identity_path
    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "course1-${var.environment}-Assets"
  default_root_object = ""


  aliases = ["images-${var.environment}.course1ahead.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.assets_bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.assets_security_headers_policy.id
    min_ttl                    = 0
    default_ttl                = 3600
    max_ttl                    = 86400
  }



  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "var.environment"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = ""
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}
################### Cloudfront distribution for Media objects################

data "aws_s3_bucket" "media" {
  bucket = var.media_bucket
}

resource "aws_cloudfront_origin_access_identity" "media" {
  comment = "OAI for Media Bucket"
}
resource "aws_cloudfront_response_headers_policy" "media_security_headers_policy" {
  name = "course1-${var.environment}-Media-Security-Headers-Policy"
  security_headers_config {
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    strict_transport_security {
      access_control_max_age_sec = "15552000"
      include_subdomains         = true
      override                   = true
    }
  }
}
resource "aws_cloudfront_distribution" "s3_media_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.media.bucket_domain_name
    origin_id   = var.media_bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.media.cloudfront_access_identity_path
    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "course1-${var.environment}-Media"
  default_root_object = ""


  aliases = ["media-${var.environment}.course1ahead.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.media_bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.media_security_headers_policy.id
    min_ttl                    = 0
    default_ttl                = 3600
    max_ttl                    = 86400
    trusted_signers            = ["self"]
  }



  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "var.environment"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = ""
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}


################### Cloudfront distribution for course1Admin Objects ################

data "aws_s3_bucket" "course1admin" {
  bucket = var.course1admin_bucket
}


resource "aws_cloudfront_origin_access_identity" "course1admin" {
  comment = "OAI for course1 Admin Bucket"
}
resource "aws_cloudfront_response_headers_policy" "course1admin_security_headers_policy" {
  name = "course1-${var.environment}-course1Admin-Security-Headers-Policy"
  security_headers_config {
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    strict_transport_security {
      access_control_max_age_sec = "15552000"
      include_subdomains         = true
      override                   = true
    }
  }
}
resource "aws_cloudfront_distribution" "s3_course1admin_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.course1admin.bucket_domain_name
    origin_id   = var.course1admin_bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.course1admin.cloudfront_access_identity_path
    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "course1-${var.environment}-Admin"
  default_root_object = "index.html"


  aliases = ["community-${var.environment}.course1ahead.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.course1admin_bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.course1admin_security_headers_policy.id
    min_ttl                    = 0
    default_ttl                = 3600
    max_ttl                    = 86400
  }



  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "var.environment"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = ""
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}


################### Cloudfront distribution for course1-course1-dev-Admin Objects ################

data "aws_s3_bucket" "course1_admin" {
  bucket = var.course1admin_bucket
}


resource "aws_cloudfront_origin_access_identity" "course1_course1_admin" {
  comment = "OAI for course1  Bucket"
}
resource "aws_cloudfront_response_headers_policy" "course1_course1_admin_security_headers_policy" {
  name = "course1-course1-${var.environment}-course1Admin-Security-Headers-Policy"
  security_headers_config {
    frame_options {
      frame_option = "DENY"
      override = true
    }
    strict_transport_security {
      access_control_max_age_sec = "15552000"
      include_subdomains = true
      override = true
    }
  }
}
resource "aws_cloudfront_distribution" "s3_course1_course1_admin_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.course1_course1_admin.bucket_domain_name
    origin_id   = var.course1admin_bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.course1_course1_admin.cloudfront_access_identity_path
    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "course1-course1-${var.environment}-Admin"
  default_root_object = "index.html"
  web_acl_id          = ""


  aliases = ["community-${var.environment}.apps.course1-capital.net"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.course1admin_bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.course1_course1_admin_security_headers_policy.id
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }



  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "var.environment"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = ""
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}


