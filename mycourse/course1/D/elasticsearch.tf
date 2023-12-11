data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnet" "private_db" {
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
  filter {
    name   = "tag:Name"
    values = ["${var.primary_name}-${var.environment_common}-db-apse1-az2"]
  }
}

//noinspection MissingModule
module "aws_es" {
  source = "git::https://github.com/lgallard/terraform-aws-elasticsearch.git?ref=0.10.0"

  domain_name           = "${var.primary_name}-${var.environment}-course1"
  elasticsearch_version = var.es_version

  cluster_config = {
    dedicated_master_enabled = "true"
    dedicated_master_type    = "t3.small.elasticsearch"
    instance_count           = "2"
    instance_type            = "t3.medium.elasticsearch"
    zone_awareness_enabled   = "false"
    availability_zone_count  = "3"
  }

  encrypt_at_rest = {
    enabled = false
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = ""
  }

  domain_endpoint_options = {
    enforce_https                   = true
    custom_endpoint_enabled         = true
    custom_endpoint                 = var.custom_endpoint
    custom_endpoint_certificate_arn = var.ssl_cert_arn
  }

  ebs_options = {
    ebs_enabled = "true"
    volume_size = var.es_volume_size
  }

  vpc_options = {
    subnet_ids         = [data.aws_subnet.private_db.id]
    security_group_ids = [aws_security_group.elasticsearch.id]
  }

  node_to_node_encryption_enabled                = false
  snapshot_options_automated_snapshot_start_hour = 23

  access_policies = templatefile("${path.module}/access_policies.tpl", {
    region      = data.aws_region.current.name,
    account     = data.aws_caller_identity.current.account_id,
    domain_name = "${var.primary_name}-${var.environment}-course1"
  })

  timeouts_update = "60m"

  tags = {
    "Name" = "${var.primary_name}-${var.environment}-course1"
  }

  log_publishing_options = {
    es_application_logs = {
      enabled  = false
    }
    search_slow_logs = {
      enabled  = false
    }
  }
}

resource "aws_route53_record" "es-domain-endpoint" {
  provider = aws.course1-non-prod-us-west-2

  zone_id    = var.public_domain_zone_id
  name       = var.custom_endpoint
  type       = "CNAME"
  ttl        = "60"
  records    = [module.aws_es.endpoint]
  depends_on = [module.aws_es]
}

resource "aws_security_group" "elasticsearch" {
  description = "AWS ElasticSearch SG"
  name        = format("%s-%s-elasticsearch-sg", var.primary_name, var.environment)
  vpc_id      = var.vpc_id

  tags = {
    "Name"        = format("%s-%s-elasticsearch-sg", var.primary_name, var.environment),
    "Environment" = var.environment
  }
}

resource "aws_security_group_rule" "es-allow-strongdm-ecs" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = var.ecs_strongdm_sg_id
  security_group_id        = aws_security_group.elasticsearch.id
  description              = "SG attached to Fargate ECS for strongdm in SC-Prod account in SIN for course1"
}

resource "aws_security_group_rule" "es-allow-eks" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ext-svc-internal.id
  security_group_id        = aws_security_group.elasticsearch.id
  description              = "${var.environment} EKS Worker Nodes"
}

resource "aws_security_group_rule" "es-allow-jumpbox" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = module.jumpbox.jumpbox-sg-id
  security_group_id        = aws_security_group.elasticsearch.id
  description              = "${var.environment} Jumpbox"
}

resource "aws_security_group_rule" "es-allow-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.elasticsearch.id
  description       = "${var.environment} VPC Cidr"
}

resource "aws_security_group_rule" "es-allow-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.elasticsearch.id
  description       = "${var.environment} VPC Cidr"
}

############# Test Env Rules #############
resource "aws_security_group_rule" "es-allow-eks-test" {
  count                    = var.allow_test ? 1 : 0
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = ""
  security_group_id        = aws_security_group.elasticsearch.id
  description              = "Test EKS Worker Nodes"
}

resource "aws_security_group_rule" "es-allow-jumpbox-test" {
  count                    = var.allow_test ? 1 : 0
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = ""
  security_group_id        = aws_security_group.elasticsearch.id
  description              = "Test Jumpbox"
}
