data "aws_vpc" "vpc" {
  state = "available"

  tags = {
    "Name" = var.vpc
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

data "aws_subnet" "public" {
  count = length(data.aws_subnet_ids.public.ids)
  id    = element(tolist(data.aws_subnet_ids.public.ids), count.index)
}

data "aws_subnet" "private_services" {
  count = length(data.aws_subnet_ids.private_services.ids)
  id    = element(tolist(data.aws_subnet_ids.private_services.ids), count.index)
}

data "aws_subnet" "private_gateway" {
  count = length(data.aws_subnet_ids.private_gateway.ids)
  id    = element(tolist(data.aws_subnet_ids.private_gateway.ids), count.index)
}
