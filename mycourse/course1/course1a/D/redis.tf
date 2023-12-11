data "aws_subnet_ids" "private_db" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.private_subnets]
  }
  filter {
    name   = "tag:Env"
    values = [var.environment_common]
  }
  filter {
    name   = "tag:Category"
    values = ["db"]
  }
}


module "elasticache" {
  source                   = "../../../../course1/modules/elasticache"
  primary_name             = var.primary_name
  service                  = "course1"
  environment              = var.environment
  cache_engine_version     = "5.0.6"
  cache_instance_type      = "cache.t3.micro"
  cache_family             = "redis5.0"
  cache_subnet_ids         = data.aws_subnet_ids.private_db.ids
  security_group_ids       = [aws_security_group.cache-sg.id]
  snapshot_arns            = [""]
  encryption_at_rest       = "true"
  key_id                   = var.kms_key_id
  snapshot_retention_limit = 5
}

resource "aws_security_group" "cache-sg" {
  name   = "${var.app_name}-${var.environment}-redis"
  vpc_id = var.vpc_id
  tags = {
    "Name" = "${var.app_name}-${var.environment}-redis"
  }
}

resource "aws_security_group_rule" "redis-allow-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cache-sg.id
  description       = "Redis egress to Internet"
}

############# Dev Env Rules #############
resource "aws_security_group_rule" "redis-allow-ecs" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = [""]
  security_group_id = aws_security_group.cache-sg.id
  description       = "${var.environment} - Redis for ECS Container Instances"
}

