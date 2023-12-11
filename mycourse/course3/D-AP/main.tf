module "jumpbox" {
  source = "../../modules/jumpbox"

  vpc                    = var.vpc
  primary_name           = var.primary_name
  environment            = var.environment
  create_iam_role        = var.create_jumpbox_iam_role
  list_of_iam_policy_arn = var.list_of_iam_policy_arn
  ami_id                 = var.jumpbox_ami_id
  tags                   = var.common_tags
}

module "course1" {
  source                             = "../../modules/course1"
  vpc_id                             = var.vpc_id
  vpc_cidr                           = var.vpc_cidr
  vpc                                = var.vpc
  primary_name                       = var.primary_name
  environment                        = var.environment
  ec2_key_name                       = var.ec2_key_name
  ssl_cert_external                  = "*.${var.ssl_cert_base_domain_name}"
  ssl_cert_internal                  = "*.${var.ssl_cert_base_domain_name}"
  bucket_name_lb_access_logs         = var.bucket_name_lb_access_logs
  course1_extra_sg                      = aws_security_group.ext-svc-internal.id
  env_identifier                     = var.env_identifier
  account_id                         = var.account_id
  tags                               = var.common_tags
  db_engine_version                  = var.db_engine_version
  enable_redis                       = var.enable_redis
  redis_subnet_ids                   = data.aws_subnet_ids.private_services.ids
  redis_instance_count               = var.redis_instance_count
  external_cidr_blocks               = var.whitelist_external_cidr_blocks
  create_sns_sqs                     = var.create_sns_sqs
  sns_sqs_iam                        = "role/${var.primary_name}-${var.environment}-apps-common"
  list_of_queue_names                = var.list_of_queue_names
  list_of_sns_names                  = [""]
  asg_desired_capacity               = var.course1_asg_desired_capacity
  db_instance_class                  = var.db_instance_class_course1
  snapshot_identifier                = var.snapshot_identifier
  enable_external_lb                 = var.enable_external_lb
  enable_internal_lb                 = var.enable_internal_lb
  list_of_cidrs_for_course1_internal_lb = var.list_of_cidrs_for_course1_internal_lb
  create_course1_iam                    = var.create_course1_iam_role
  list_of_extra_sgs_for_lb           = [aws_security_group.cloudfront_sg.id, aws_security_group.cloudfront_sg_1.id]
  depends_on                         = [aws_iam_role.eks_pod_iam_role]
  snapshot_arns                      = [""]
  key_id                             = ""
}

resource "aws_security_group" "ext-svc-internal" {
  description = "${var.primary_name}-${var.environment}-ext-svc-internal"
  name        = "${var.primary_name}-${var.environment}-ext-svc-internal"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "${var.primary_name}-${var.environment}-ext-svc-internal"
  }
}

resource "aws_security_group_rule" "ext-svc-internal-egress" {
  security_group_id = aws_security_group.ext-svc-internal.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "alb-ingress-controller-sg-rule-egress" {
  security_group_id = module.course1.course1-security-group-external

  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = module.eks.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "alb-ingress-controller-sg-rule-ingress" {
  security_group_id = module.eks.cluster_primary_security_group_id

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = module.course1.course1-security-group-external
}

resource "aws_route53_record" "eks-internal-lb" {
  zone_id        = var.public_domain_zone_id
  name           = var.eks_internal_lb_dns_value
  type           = "CNAME"
  ttl            = "300"
  set_identifier = "api-${var.region_short}"
  geolocation_routing_policy {
    continent = "AS"
  }
  records = [var.eks_internal_lb_dns]
}


resource "aws_route53_record" "course1-external-lb-regional" {
  zone_id = var.public_domain_zone_id
  name    = "course1-${var.environment}-${var.region_short}.${var.ssl_cert_base_domain_name}"
  type    = "CNAME"
  ttl     = "60"
  records = module.course1.course1-external-lb-dns
}

resource "aws_route53_record" "eks-internal-lb-hub" {
  provider = aws.course1-non-prod-us-west-2

  zone_id        = var.public_domain_zone_id
  name           = var.eks_internal_lb_dns_value_hub
  type           = "CNAME"
  ttl            = "300"
  set_identifier = "nonprod-${var.region_short}"
  geolocation_routing_policy {
    continent = "AS"
  }
  records = [var.eks_internal_lb_dns_hub]
}

resource "aws_security_group" "cloudfront_sg" {
  description = "${var.primary_name}-${var.environment}-cloudfront"
  name        = "${var.primary_name}-${var.environment}-cloudfront"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "${var.primary_name}-${var.environment}-cloudfront"
  }
}

resource "aws_security_group_rule" "cloudfront_sg_rule" {
  for_each          = var.whitelist_cloudfront_ips
  security_group_id = aws_security_group.cloudfront_sg.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = each.value

  cidr_blocks = [each.key]
}

resource "aws_security_group" "cloudfront_sg_1" {
  description = "${var.primary_name}-${var.environment}-cloudfront-1"
  name        = "${var.primary_name}-${var.environment}-cloudfront-1"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "${var.primary_name}-${var.environment}-cloudfront-1"
  }
}

resource "aws_security_group_rule" "cloudfront_sg_rule_1" {
  for_each          = var.whitelist_cloudfront_ips_1
  security_group_id = aws_security_group.cloudfront_sg_1.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = each.value

  cidr_blocks = [each.key]
}

data "aws_iam_policy_document" "course1-ssm" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = [module.course1.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "course1-ssm" {
  count = var.create_course1_iam_role ? 0 : 1
  name  = format("%s-%s-ssm-apse1", "course1", var.environment)
  role  = format("%s-%s", "course1", var.environment)

  policy = data.aws_iam_policy_document.course1-ssm.json
}
