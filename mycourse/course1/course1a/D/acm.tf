resource "aws_acm_certificate" "cert_global" {
  provider                  = aws.virginia
  domain_name               = "*.${var.domain_name_global}"
  validation_method         = "DNS"
  subject_alternative_names = [var.domain_name_global]

  tags = {
    Name = var.domain_name_global
    Env  = var.environment
  }
  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_acm_certificate" "cert" {
  domain_name               = "${var.domain_name}"
  validation_method         = "DNS"

  tags = {
    Name = var.domain_name
    Env  = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}