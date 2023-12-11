resource "aws_acm_certificate" "cert-use1" {
  provider                  = aws.us-east-1
  domain_name               = "*.${var.domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = [var.domain_name]

  tags = {
    Name = var.domain_name
    Env  = "non-prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

