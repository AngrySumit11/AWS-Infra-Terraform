locals {
  cluster_name = "${var.primary_name}-${var.environment}-apps"
}

module "jumpbox" {
  source = "../../modules/jumpbox"

  vpc                    = var.vpc
  primary_name           = var.primary_name
  environment            = var.environment
  list_of_iam_policy_arn = var.list_of_iam_policy_arn
  ami_id                 = var.jumpbox_ami_id
  ssh_public_key         = ""
  tags                   = var.common_tags
}

module "course1" {
  source                     = "../../modules/course1"
  vpc_id                     = var.vpc_id
  vpc_cidr                   = var.vpc_cidr
  vpc                        = var.vpc
  primary_name               = var.primary_name
  environment                = var.environment
  ec2_key_name               = var.ec2_key_name
  ssl_cert_external          = "*.${var.ssl_cert_base_domain_name}"
  ssl_cert_internal          = "*.${var.ssl_cert_base_domain_name}"
  bucket_name_lb_access_logs = var.bucket_name_lb_access_logs
  course1_extra_sg              = aws_security_group.ext-svc-internal.id
  env_identifier             = var.env_identifier
  account_id                 = var.account_id
  tags                       = var.common_tags
  db_engine_version          = var.db_engine_version
  enable_redis               = var.enable_redis  
  redis_instance_type        = var.redis_instance_type
  redis_engine_version       = "5.0.6"
  enable_redis_encryption    = var.enable_redis_encryption
  redis_subnet_ids           = data.aws_subnet_ids.private_services.ids
  redis_instance_count       = var.redis_instance_count
  external_cidr_blocks       = var.whitelist_external_cidr_blocks
  create_sns_sqs             = var.create_sns_sqs
  sns_sqs_iam                = "role/${var.primary_name}-${var.environment}-apps-common"
  list_of_queue_names        = var.list_of_queue_names
  list_of_sns_names          = ["notification"]
  asg_desired_capacity       = var.course1_asg_desired_capacity
  db_instance_class          = var.db_instance_class_course1
  snapshot_identifier        = var.snapshot_identifier
  enable_internal_lb         = var.enable_internal_lb
  depends_on                 = [aws_iam_role.eks_pod_iam_role]
  snapshot_arns              = [""]
  encryption_at_rest         = "true"
  key_id                     = "arn:aws:kms:ap-southeast-1:accountid:key"   
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
  provider = aws.course1-non-prod-us-west-2

  zone_id = var.public_domain_zone_id
  name    = var.eks_internal_lb_dns_value
  type    = "CNAME"
  ttl     = "60"
  records = [var.eks_internal_lb_dns]
}

resource "aws_route53_record" "course1-external-lb" {
  provider = aws.course1-non-prod-us-west-2

  zone_id = var.public_domain_zone_id
  name    = var.course1_external_lb_dns_value
  type    = "CNAME"
  ttl     = "60"
  records = var.environment == "dev" ? module.course1.course1-external-lb-dns : [var.course1_external_lb_dns_record_value]
  //  records = ["${var.course1_external_lb_dns_value}.cdn.cloudflare.net"]
}

resource "aws_route53_record" "course1-internal-lb" {
  provider = aws.course1-non-prod-us-west-2

  zone_id = var.public_domain_zone_id
  name    = var.course1_internal_lb_dns_value
  type    = "CNAME"
  ttl     = "60"
  records = module.course1.course1-internal-lb-dns
}

resource "aws_route53_record" "alb-external-web" {
  count    = var.create_alb_ingress_controller && var.create_alb_ingress_dns ? 1 : 0
  provider = aws.course1-non-prod-us-west-2

  zone_id = var.public_domain_zone_id
  name    = var.web_external_lb_dns_value
  type    = "CNAME"
  ttl     = "60"
  records = [var.course1_web_ext_alb_dns]
  //  records = ["${var.web_external_lb_dns_value}.cdn.cloudflare.net"]
}

resource "aws_route53_record" "alb-external-weblink" {
  count    = var.create_alb_ingress_controller && var.create_alb_ingress_dns_weblink ? 1 : 0
  provider = aws.course1-non-prod-us-west-2

  zone_id = var.public_domain_zone_id
  name    = var.weblink_external_lb_dns_value
  type    = "CNAME"
  ttl     = "3600"
  records = [var.weblink_ext_alb_dns]
  //  records = ["${var.web_external_lb_dns_value}.cdn.cloudflare.net"]
}

resource "aws_route53_record" "alb-external-web-course1" {
  count    = var.create_alb_ingress_controller && var.create_alb_ingress_dns_course1 ? 1 : 0
  provider = aws.course1-non-prod-us-west-2

  zone_id = var.public_domain_zone_id
  name    = var.course1_web_external_lb_dns_value
  type    = "CNAME"
  ttl     = "60"
  records = [var.course1_web_ext_alb_dns]
  //  records = ["${var.web_external_lb_dns_value}.cdn.cloudflare.net"]
}

resource "aws_ses_receipt_rule" "ses-receipt-rule" {
  provider = aws.course1-us-west-2

  name          = "${var.primary_short_name}-sdcrm-${var.environment}"
  rule_set_name = "${var.primary_short_name}-sdcrm-main"
  recipients    = ["${var.primary_short_name}-sdcrm-${var.environment}@${var.ssl_cert_base_domain_name}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = var.ses_rule_bucket_name
    position          = var.ses_rule_sdcrm_position
    object_key_prefix = var.environment
  }
}

resource "aws_ses_receipt_rule" "ses-receipt-rule-finance" {
  provider = aws.course1-us-west-2

  count         = var.enable_ses_rule_finance ? 1 : 0
  name          = "${var.primary_short_name}-finance-${var.environment}"
  rule_set_name = "${var.primary_short_name}-sdcrm-main"
  recipients    = ["${var.primary_short_name}-finance-${var.environment}@${var.ssl_cert_base_domain_name}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = var.ses_rule_bucket_name
    position          = var.ses_rule_finance_position
    object_key_prefix = "egnyte"
  }
}

resource "aws_ses_receipt_rule" "ses-receipt-rule-journal" {
  provider = aws.course1-us-west-2

  count         = var.enable_ses_rule_journal ? 1 : 0
  name          = "${var.primary_short_name}-mail-journal-${var.environment_common}"
  rule_set_name = "${var.primary_short_name}-sdcrm-main"
  recipients    = ["${var.primary_short_name}-mail-journal-${var.environment_common}@${var.ssl_cert_base_domain_name}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = var.ses_rule_bucket_name_journal
    position          = var.ses_rule_journal_position
    object_key_prefix = ""
  }
}
