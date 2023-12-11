# AWS Data
data "aws_vpc" "vpc" {
  state = "available"

  filter {
    name   = "tag:Name"
    values = [var.vpc]
  }
}

data "aws_region" "current" {}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.public_subnets]
  }
  filter {
    name   = "tag:Env"
    values = [var.environment]
  }
  filter {
    name   = "tag:Category"
    values = ["public"]
  }
}

data "aws_subnet_ids" "private_gateway" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.private_subnets]
  }
  filter {
    name   = "tag:Env"
    values = [var.environment]
  }
  filter {
    name   = "tag:Category"
    values = ["gateway"]
  }
}

data "aws_subnet_ids" "private_services" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.private_subnets]
  }
  filter {
    name   = "tag:Env"
    values = [var.environment]
  }
  filter {
    name   = "tag:Category"
    values = ["services"]
  }
}

data "aws_acm_certificate" "external-cert" {
  count  = var.use_ssl_certificate ? 1 : 0
  domain = var.ssl_cert_external
  most_recent = false
}

data "aws_acm_certificate" "internal-cert" {
  count  = var.use_ssl_certificate ? 1 : 0
  domain = var.ssl_cert_internal
  most_recent = false
}

