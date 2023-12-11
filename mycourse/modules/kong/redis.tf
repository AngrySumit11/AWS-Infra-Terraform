resource "aws_elasticache_replication_group" "course1" {
  count = var.enable_redis ? 1 : 0

  replication_group_id          = format("%s-%s", var.service, var.environment)
  replication_group_description = var.description

  engine                = "redis"
  engine_version        = var.redis_engine_version
  node_type             = var.redis_instance_type
  number_cache_clusters = var.redis_instance_count
  parameter_group_name  = aws_elasticache_parameter_group.course1[count.index].id
  port                  = 6379

  subnet_group_name  = aws_elasticache_subnet_group.course1[count.index].name
  security_group_ids = [aws_security_group.redis.id]

  tags = {
    "Name"        = format("%s-%s", var.service, var.environment),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service
  }

  depends_on = [aws_security_group.redis]
}

resource "aws_elasticache_parameter_group" "course1" {
  count  = var.enable_redis ? 1 : 0
  name   = format("%s-%s", var.service, var.environment)
  family = var.redis_family

  description = var.description
}

resource "aws_elasticache_subnet_group" "course1" {
  count      = var.enable_redis ? 1 : 0
  name       = format("%s-%s-cache-subnets", var.service, var.environment)
  subnet_ids = var.redis_subnet_ids
  tags = {
    "Name" = format("%s-%s-cache-subnets", var.service, var.environment)
  }
}

########### Redis Encryption   #################
resource "aws_elasticache_replication_group" "course1_encryption" {
  count = var.enable_redis_encryption ? 1 : 0

  replication_group_id          = format("%s-%s-encryption", var.service, var.environment)
  replication_group_description = var.description

  engine                = "redis"
  engine_version        = var.redis_engine_version
  node_type             = var.redis_instance_type
  number_cache_clusters = var.redis_instance_count
  parameter_group_name  = aws_elasticache_parameter_group.course1_encryption[count.index].id
  port                  = 6379

  subnet_group_name  = aws_elasticache_subnet_group.course1_encryption[count.index].name
  security_group_ids = [aws_security_group.redis.id]

  snapshot_arns              = var.snapshot_arns
  at_rest_encryption_enabled = var.encryption_at_rest
  kms_key_id = var.key_id

  tags = {
    "Name"        = format("%s-%s-encryption", var.service, var.environment),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service
  }

  depends_on = [aws_security_group.redis]
}

resource "aws_elasticache_parameter_group" "course1_encryption" {
  count  = var.enable_redis_encryption ? 1 : 0
  name   = format("%s-%s-encryption", var.service, var.environment)
  family = var.redis_family

  description = var.description
}

resource "aws_elasticache_subnet_group" "course1_encryption" {
  count      = var.enable_redis_encryption ? 1 : 0
  name       = format("%s-%s-encryption-cache-subnets", var.service, var.environment)
  subnet_ids = var.redis_subnet_ids
  tags = {
    "Name" = format("%s-%s-encryption-cache-subnets", var.service, var.environment)
  }
}
