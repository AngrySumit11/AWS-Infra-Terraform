module "elasticache-api" {
  source               = "../../modules/elasticache"
  primary_name         = var.primary_name
  service              = "api"
  environment          = var.environment_common
  cache_engine_version = "5.0.6"
  cache_instance_type  = "cache.t3.small"
  cache_family         = "redis5.0"
  cache_subnet_ids     = data.aws_subnet_ids.private_db_common.ids
  security_group_ids   = [aws_security_group.cache-sg-course1.id]
  #snapshot_arns        = [""]
  encryption_at_rest   = "true"
  key_id               = ""
}

resource "aws_security_group" "cache-sg-course1" {
  name   = "${var.primary_name}-course1-${var.environment_common}"
  vpc_id = var.vpc_id
  tags = {
    "Name" = "${var.primary_name}-course1-${var.environment_common}"
  }
}

resource "aws_security_group_rule" "redis-allow-egress-course1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cache-sg-course1.id
  description       = "Redis egress to Internet"
}

############# ${var.environment} Env Rules #############
resource "aws_security_group_rule" "redis-allow-eks-course1" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ext-svc-internal.id
  security_group_id        = aws_security_group.cache-sg-course1.id
  description              = "${var.environment} - Redis for EKS Worker Nodes"
}

resource "aws_security_group_rule" "redis-allow-jumpbox-course1" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.jumpbox.jumpbox-sg-id
  security_group_id        = aws_security_group.cache-sg-course1.id
  description              = "${var.environment} - Redis for jumpbox"
}
