
### ELASTIC CACHE with Encryption ###

resource "aws_elasticache_replication_group" "cache-encryption" {
  count = var.enable_cache ? 1 : 0

  replication_group_id          = format("%s-%s-%s-encryption", var.primary_name, var.service, var.environment)
  replication_group_description = var.description

  engine                   = var.cache_engine
  engine_version           = var.cache_engine_version
  node_type                = var.cache_instance_type
  number_cache_clusters    = var.cache_instance_count
  parameter_group_name     = aws_elasticache_parameter_group.cache-parameter-group-encryption[count.index].id
  port                     = 6379
  subnet_group_name        = aws_elasticache_subnet_group.cache-subnet-group-encryption[count.index].name
  security_group_ids       = var.security_group_ids
  snapshot_arns            = var.snapshot_arns
  snapshot_retention_limit = var.snapshot_retention_limit
  at_rest_encryption_enabled = var.encryption_at_rest
  kms_key_id = var.key_id

  tags = {
    "Name"        = format("%s-%s-%s-encryption", var.primary_name, var.service, var.environment)
    "Description" = var.description
  }
}

resource "aws_elasticache_parameter_group" "cache-parameter-group-encryption" {
  count       = var.enable_cache ? 1 : 0
  name        = format("%s-%s-%s-encryption", var.primary_name, var.service, var.environment)
  family      = var.cache_family
  description = var.description
  tags = {
    "Name"    = format("%s-%s-%s-encryption", var.primary_name, var.service, var.environment)
  }
}

resource "aws_elasticache_subnet_group" "cache-subnet-group-encryption" {
  count      = var.enable_cache ? 1 : 0
  name       = format("%s-%s-%s-encryption-cache-subnets", var.primary_name, var.service, var.environment)
  subnet_ids = var.cache_subnet_ids
  tags = {
    "Name" = format("%s-%s-%s-encryption-cache-subnets", var.primary_name, var.service, var.environment)
  }
}
