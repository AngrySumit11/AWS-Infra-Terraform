# PostgreSQL security group
resource "aws_security_group" "postgresql" {
  description = "course1 RDS instance"
  name        = format("%s-%s-%s-postgresql-security-grp", var.primary_name, var.environment, var.service)
  vpc_id      = var.vpc_id

  tags = {
    "Name"        = format("%s-%s-%s-postgresql-security-grp", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}

resource "aws_security_group_rule" "postgresql-ingress-course1" {
  security_group_id = aws_security_group.postgresql.id

  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
  description              = "${var.environment} course1 servers"
}

# Redis security group
resource "aws_security_group" "redis" {
  description = "course1 redis cluster"
  name        = format("%s-%s-%s-redis", var.primary_name, var.environment, var.service)
  vpc_id      = var.vpc_id

  tags = {
    "Name"        = format("%s-%s-%s-redis", var.primary_name, var.environment, var.service)
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service
  }
}

resource "aws_security_group_rule" "redis-ingress-course1" {
  security_group_id = aws_security_group.redis.id

  type      = "ingress"
  from_port = 6379
  to_port   = 6379
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

# course1 node security group and rules
resource "aws_security_group" "course1" {
  description = "course1 EC2 instances"
  name        = format("%s-%s-%s-ec2-security-grp", var.primary_name, var.environment, var.service)
  vpc_id      = var.vpc_id
  tags = {
    "Name"        = format("%s-%s-%s-ec2-security-grp", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}

# External load balancer access
resource "aws_security_group_rule" "proxy-ingress-external-lb" {
  security_group_id = aws_security_group.course1.id

  type      = "ingress"
  from_port = 8000
  to_port   = 8000
  protocol  = "tcp"

  source_security_group_id = aws_security_group.external-lb.id
}

resource "aws_security_group_rule" "admin-ingress-external-lb" {
  security_group_id = aws_security_group.course1.id

  type      = "ingress"
  from_port = 8001
  to_port   = 8001
  protocol  = "tcp"

  source_security_group_id = aws_security_group.external-lb.id
}

# Internal load balancer access
resource "aws_security_group_rule" "proxy-ingress-internal-lb" {
  security_group_id = aws_security_group.course1.id

  type      = "ingress"
  from_port = 8000
  to_port   = 8000
  protocol  = "tcp"

  source_security_group_id = aws_security_group.internal-lb.id
}

resource "aws_security_group_rule" "admin-ingress-internal-lb" {
  security_group_id = aws_security_group.course1.id

  type      = "ingress"
  from_port = 8001
  to_port   = 8001
  protocol  = "tcp"

  source_security_group_id = aws_security_group.internal-lb.id
}

resource "aws_security_group_rule" "manager-ingress-internal-lb" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.course1.id

  type      = "ingress"
  from_port = 8002
  to_port   = 8002
  protocol  = "tcp"

  source_security_group_id = aws_security_group.internal-lb.id
}

resource "aws_security_group_rule" "portal-gui-ingress-internal-lb" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.course1.id

  type      = "ingress"
  from_port = 8003
  to_port   = 8003
  protocol  = "tcp"

  source_security_group_id = aws_security_group.internal-lb.id
}

resource "aws_security_group_rule" "portal-ingress-internal-lb" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.course1.id

  type      = "ingress"
  from_port = 8004
  to_port   = 8004
  protocol  = "tcp"

  source_security_group_id = aws_security_group.internal-lb.id
}

# HTTP outbound for Debian packages
resource "aws_security_group_rule" "course1-egress-http" {
  security_group_id = aws_security_group.course1.id

  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# HTTPS outbound for awscli, course1
resource "aws_security_group_rule" "course1-egress-https" {
  security_group_id = aws_security_group.course1.id

  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# Load balancers
# External
resource "aws_security_group" "external-lb" {
  description = "course1 External Load Balancer"
  name        = format("%s-%s-%s-external-lb", var.primary_name, var.environment, var.service)
  vpc_id      = var.vpc_id

  tags = {
    "Name"        = format("%s-%s-%s-external-lb", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}

resource "aws_security_group_rule" "external-lb-ingress-proxy" {
  for_each          = var.external_cidr_blocks
  security_group_id = aws_security_group.external-lb.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = each.value

  cidr_blocks = [each.key]
}

resource "aws_security_group_rule" "external-lb-egress-proxy" {
  security_group_id = aws_security_group.external-lb.id

  type      = "egress"
  from_port = 8000
  to_port   = 8000
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

resource "aws_security_group_rule" "external-lb-egress-admin" {
  security_group_id = aws_security_group.external-lb.id

  type      = "egress"
  from_port = 8001
  to_port   = 8001
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

# Internal
resource "aws_security_group" "internal-lb" {
  description = "course1 Internal Load Balancer"
  name        = format("%s-%s-%s-internal-lb", var.primary_name, var.environment, var.service)
  vpc_id      = var.vpc_id

  tags = {
    "Name"        = format("%s-%s-%s-internal-lb", var.primary_name, var.environment, var.service),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}

resource "aws_security_group_rule" "internal-lb-http-others" {
  count             = length(var.list_of_cidrs_for_course1_internal_lb) > 0 ? 1 : 0
  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = var.list_of_cidrs_for_course1_internal_lb
}

resource "aws_security_group_rule" "internal-lb-https-others" {
  count             = length(var.list_of_cidrs_for_course1_internal_lb) > 0 ? 1 : 0
  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = var.list_of_cidrs_for_course1_internal_lb
}

resource "aws_security_group_rule" "internal-lb-ingress-proxy-http" {
  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = [var.vpc_cidr]
}

resource "aws_security_group_rule" "internal-lb-ingress-proxy-https" {
  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = [var.vpc_cidr]
}

resource "aws_security_group_rule" "internal-lb-ingress-admin" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 8444
  to_port   = 8444
  protocol  = "tcp"

  cidr_blocks = var.admin_cidr_blocks
}

resource "aws_security_group_rule" "internal-lb-ingress-manager" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 8445
  to_port   = 8445
  protocol  = "tcp"

  cidr_blocks = var.manager_cidr_blocks
}

resource "aws_security_group_rule" "internal-lb-ingress-portal-gui" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 8446
  to_port   = 8446
  protocol  = "tcp"

  cidr_blocks = var.portal_cidr_blocks
}

resource "aws_security_group_rule" "internal-lb-ingress-portal" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.internal-lb.id

  type      = "ingress"
  from_port = 8447
  to_port   = 8447
  protocol  = "tcp"

  cidr_blocks = var.portal_cidr_blocks
}

resource "aws_security_group_rule" "internal-lb-egress-proxy" {
  security_group_id = aws_security_group.internal-lb.id

  type      = "egress"
  from_port = 8000
  to_port   = 8000
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

resource "aws_security_group_rule" "internal-lb-egress-admin" {
  security_group_id = aws_security_group.internal-lb.id

  type      = "egress"
  from_port = 8001
  to_port   = 8001
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

resource "aws_security_group_rule" "internal-lb-egress-manager" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.internal-lb.id

  type      = "egress"
  from_port = 8002
  to_port   = 8002
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

resource "aws_security_group_rule" "internal-lb-egress-portal-gui" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.internal-lb.id

  type      = "egress"
  from_port = 8003
  to_port   = 8003
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

resource "aws_security_group_rule" "internal-lb-egress-portal" {
  count = var.enable_ee ? 1 : 0

  security_group_id = aws_security_group.internal-lb.id

  type      = "egress"
  from_port = 8004
  to_port   = 8004
  protocol  = "tcp"

  source_security_group_id = aws_security_group.course1.id
}

resource "aws_security_group_rule" "course1-ssh-vpc" {
  security_group_id = aws_security_group.course1.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [var.vpc_cidr]
}
