data "aws_vpc" "vpc" {
  state = "available"

  tags = {
    "Name" = var.vpc
  }
}

data "aws_subnet_ids" "private_services" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.private_subnets]
  }
  # filter {
  #   name   = "tag:Env"
  #   values = ["dev"]
  # }
  # filter {
  #   name   = "tag:Category"
  #   values = ["services"]
  # }
}


data "aws_subnet" "private_services" {
  count = length(data.aws_subnet_ids.private_services.ids)
  id    = element(tolist(data.aws_subnet_ids.private_services.ids), count.index)
}

