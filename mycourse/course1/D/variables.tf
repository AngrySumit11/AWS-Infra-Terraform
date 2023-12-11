variable "account_id" {
  description = "AWS Account Id"
  type        = string
  default     = ""
}

variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
}

variable "common_tags" {
  type = map(string)
  default = {
    
  }
}

variable "list_of_iam_policy_arn" {
  type = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

variable "primary_short_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
}

variable "course1_asg_desired_capacity" {
  type    = number
  default = 1
}

variable "env_identifier" {
  description = "Env identifier as per github branch"
  type        = string
  default     = "-develop"
}

variable "eks_instance_types" {
  type    = list(string)
  default = ["c5a.xlarge", "c5.xlarge", "c4.xlarge"]
}

variable "eks_desired_capacity" {
  type    = number
  default = 3
}

variable "eks_max_capacity" {
  type    = number
  default = 8
}

variable "eks_min_capacity" {
  type    = number
  default = 3
}

variable "node_k8s_labels" {
  type    = string
  default = "non-group"
}

variable "jumpbox_ami_id" {
  type    = string
  default = ""
}

variable "api_list" {
  description = "List of API names"
  type        = list(string)
  default = [""]
}

variable "api_list_iam_roles" {
  description = "List of API names which needs iam access"
  type        = list(string)
  default     = ["common", "ALBIngressController"]
}

variable "api_list_iam_roles_service_account" {
  description = "List of service accounts"
  type        = list(string)
  default     = ["course1-dev-apps-common", "alb-ingress-controller"]
}

variable "api_list_iam_roles_namespaces" {
  description = "List of namespaces"
  type        = list(string)
  default     = ["default", "kube-system"]
}

variable "list_of_queue_names" {
  type    = list(string)
  default = ["notification"]
}

variable "environment" {
  description = "Env name"
  type        = string
  default     = "dev"
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
  default     = "course1-non-prod"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "subnet_tag" {
  description = "Tag used on subnets to define Tier"
  type        = string
  default     = "Tier"
}

variable "private_subnets" {
  description = "Subnet tag on private subnets"
  type        = string
  default     = "private"
}

variable "public_subnets" {
  description = "Subnet tag on public subnets for external load balancers"
  type        = string
  default     = "public"
}

variable "ec2_key_name" {
  description = "Public ssh key name"
  type        = string
  default     = "default-keypair"
}

variable "ssl_cert_base_domain_name" {
  description = "SSL cert domain name"
  type        = string
  default     = ""
}

variable "bucket_name_lb_access_logs" {
  description = "S3 Bucket name for LB Logging"
  type        = string
  default     = ""
}

variable "db_engine_version" {
  description = "Postgres DB Version name"
  type        = string
  default     = "11.13"
}

variable "whitelist_external_cidr_blocks" {
  description = "List of CIDRs to whitelist"
  type        = map(any)
  default = {
   
  }
}

variable "enable_redis" {
  description = "Boolean to enable redis AWS resource"
  type        = bool
  default     = true
}

variable "enable_redis_encryption" {
  description = "Boolean to enable redis AWS resource"
  type        = string
  default     = false
}
variable "create_sns_sqs" {
  type    = bool
  default = true
}

variable "public_domain_zone_id" {
  type    = string
  default = ""
}

variable "eks_internal_lb_dns" {
  type    = string
  default = ""
}



variable "namespace" {
  type    = string
  default = "default"
}

variable "create_alb_ingress_controller" {
  type    = bool
  default = true
}

variable "db_instance_class_course1" {
  default = "db.t3.small"
}

variable "snapshot_identifier" {
  type    = string
  default = ""
}

variable "s3_bucket_names" {
  type    = list(string)
  default = [""]
}

variable "ecs_strongdm_sg_id" {
  type    = string
  default = ""
}

variable "db_instance_class_api" {
  default = "db.t3.small"
}

variable "create_alb_ingress_dns" {
  type    = bool
  default = true
}

variable "create_alb_ingress_dns_weblink" {
  type    = bool
  default = true
}

variable "create_alb_ingress_dns_course1" {
  type    = bool
  default = true
}

variable "redis_instance_count" {
  description = "Number of redis nodes"
  type        = string
  default     = 1
}

variable "ses_rule_bucket_name" {
  type    = string
  default = "course1-sdcrm-mail-non-prod"
}

variable "ses_rule_bucket_name_journal" {
  type    = string
  default = "course1-mail-journal-non-prod"
}

variable "ssl_cert_arn" {
  type    = string
  default = ""
}

variable "environment_common" {
  type    = string
  default = "non-prod"
}

variable "allow_test" {
  type    = bool
  default = true
}

variable "allow_stage" {
  type    = bool
  default = true
}

variable "enable_course1_rds" {
  type    = bool
  default = true
}

variable "enable_ses_rule_finance" {
  type    = bool
  default = true
}

variable "enable_ses_rule_journal" {
  type    = bool
  default = true
}

variable "ses_rule_sdcrm_position" {
  type    = number
  default = 1
}

variable "ses_rule_finance_position" {
  type    = number
  default = 1
}

variable "ses_rule_journal_position" {
  type    = number
  default = 1
}

variable "enable_internal_lb" {
  description = "Boolean to enable/create the internal load balancer for the forward proxy"
  type        = string
  default     = true
}

variable "es_version" {
  type    = string
  default = "7.10"
}

variable "custom_endpoint" {
  type    = string
  default = ""
}

variable "es_volume_size" {
  type    = string
  default = "30"
}

variable "snapshot_identifier_documentDB" {
  type        = string
  default     = ""
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
}
variable "redis_instance_type" {
  description = "Redis node instance type"
  type        = string
  default     = "cache.t2.medium"
}

variable "course1_snapshot_identifier" {
  type    = string
  default = "course1-dev-v14-en" # Need to update with right details
  description = ""
}

variable "encryption_at_rest" {
  type    = bool
  default = true
  description = "DB encryption status"
}

variable "kms_key_id" {
  type    = string
  default = ""
  description = "KMS encryption key"
}

variable "db_family" {
  default = "postgres14"
  description = "DB Parameter group version"
}

variable "service" {
  default = "course1"
  description = "service name"
}
