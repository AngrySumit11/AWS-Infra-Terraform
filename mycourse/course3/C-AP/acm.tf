resource "aws_acm_certificate" "cert" {
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

resource "aws_route53_zone" "zone" {
  count = var.create_route53_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name = var.domain_name
    Env  = "non-prod"
  }
}

data "aws_route53_zone" "zone" {
  count        = var.create_route53_zone ? 0 : 1
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "cert-dns-record" {
  for_each = {
    for domain in aws_acm_certificate.cert.domain_validation_options : domain.domain_name => {
      name    = domain.resource_record_name
      record  = domain.resource_record_value
      type    = domain.resource_record_type
      zone_id = var.create_route53_zone ? aws_route53_zone.zone[0].zone_id : data.aws_route53_zone.zone[0].zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "cert-dns-validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-dns-record : record.fqdn]
}
