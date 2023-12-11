##############################################################################
##### Multi region setup for hub apps
##############################################################################

module "cloudfront" {
  source = "../../modules/cloudfront"

  aliases = [""]

  comment             = "${var.primary_name} ${var.environment} Multi Region"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false
  logging_config      = {}
  web_acl_id          = ""

  origin = {
    usw2 = {
      domain_name = module.course1.course1-external-lb-dns[0]
      origin_id   = "${var.primary_name}-${var.environment}-lb-${var.region_short}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
      }
    }

    apse1 = {
      domain_name = var.apse1_domain_name
      origin_id   = "${var.primary_name}-${var.environment}-lb-apse1"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "${var.primary_name}-${var.environment}-lb-${var.region_short}"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = false
    use_forwarded_values       = false
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.cf_origin_request_policy.id
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"

    lambda_function_association = {
      origin-request = {
        lambda_arn = "arn:aws:lambda:us-east-1:${var.account_id}:function:${var.primary_name}-${var.environment}-lambda:9"
      }
    }
  }

  ordered_cache_behavior = [
    {
      path_pattern           = ""
      target_origin_id       = "${var.primary_name}-${var.environment}-lb-${var.region_short}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = false
      use_forwarded_values       = false
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    },
    {
      path_pattern           = ""
      target_origin_id       = "${var.primary_name}-${var.environment}-lb-${var.region_short}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = false
      use_forwarded_values       = false
      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"      
    },
    {
      path_pattern           = ""
      target_origin_id       = "${var.primary_name}-${var.environment}-lb-${var.region_short}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = true
      use_forwarded_values       = false
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"      
    },
    {
      path_pattern           = ""
      target_origin_id       = "${var.primary_name}-${var.environment}-lb-${var.region_short}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = true
      use_forwarded_values       = false
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    },
    {
      path_pattern           = "/"
      target_origin_id       = "${var.primary_name}-${var.environment}-lb-apse1"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = false
      use_forwarded_values       = false
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "153640c2-a51c-4982-a828-1529ffa15001"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"

      lambda_function_association = {
        origin-request = {
          lambda_arn = "arn:aws:lambda:us-east-1:${var.account_id}:function:${var.primary_name}-${var.environment}-lambda:9"
        }
      }
    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = ""
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
  depends_on = [aws_cloudfront_origin_request_policy.cf_origin_request_policy]
}



module "lambda_edge_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"
  providers = {
    aws = aws.course1-non-prod-us-east-1
  }

  function_name = "${var.primary_name}-${var.environment}-lambda"
  description   = "My awesome lambda function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  publish        = true
  lambda_at_edge = true

  source_path = "./lambda_function.py"
}

resource "aws_cloudfront_origin_request_policy" "cf_origin_request_policy" {
  name    = "cf-allviewer-and-country-headers-${var.environment}"
  comment = "cf-allviewer-and-country-headers-${var.environment}"
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewerAndWhitelistCloudFront"
    headers {
      items = ["CloudFront-Viewer-Country"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
