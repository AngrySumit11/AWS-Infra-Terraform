data "aws_subnet_ids" "private_db_course1_elastic_cache" {
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

module "elasticache_course1_non_prod" {
  source                   = "../../modules/elasticache_course1"
  primary_name             = var.primary_name
  environment              = var.environment_common
  cache_engine_version     = "5.0.6"
  cache_instance_type      = "cache.t3.micro"
  cache_family             = "redis5.0"
  cache_subnet_ids         = data.aws_subnet_ids.private_db_course1_elastic_cache.ids
  security_group_ids       = [aws_security_group.cache-sg.id]
 # snapshot_arns            = ["arn:aws:s3:::course1-course1-s3-backup-dev/course1-course1-dev-backup-2022-07-11-0001.rdb"]
  encryption_at_rest       = "true"
  key_id                   = ""
  snapshot_retention_limit = 5
}

module "elasticache_course1_non_prod_admin" {
  source                   = "../../modules/elasticache_course1"
  primary_name             = var.primary_name
  environment              = "non-prod-admin"
  cache_engine_version     = "5.0.6"
  cache_instance_type      = "cache.t3.micro"
  cache_family             = "redis5.0"
  cache_subnet_ids         = data.aws_subnet_ids.private_db_course1_elastic_cache.ids
  security_group_ids       = [aws_security_group.cache-sg.id]
 # snapshot_arns            = ["arn:aws:s3:::course1-course1-s3-backup-dev/course1-course1-dev-backup-2022-07-11-0001.rdb"]
  encryption_at_rest       = "true"
  key_id                   = ""
  snapshot_retention_limit = 5
}

