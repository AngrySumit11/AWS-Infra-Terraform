resource "aws_acm_certificate" "cert" {
  domain_name               = "*.${var.domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = [var.domain_name]

  tags = {
    Name = var.domain_name
    Env  = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "dev" {
  count = var.create_route53_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name = var.domain_name
    Env  = var.environment
  }
}
