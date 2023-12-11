locals {
  cluster_name     = "${var.primary_name}-${var.environment}-apps"
  hub_cluster_name = "${var.primary_name}-${var.environment}-hub-apps"
}

variable "account_id" {
  description = "AWS Account Id"
  type        = string
  default     = ""
}

variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = ""
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
  default     = "sc"
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
  default = 5
}

variable "eks_max_capacity" {
  type    = number
  default = 13
}

variable "eks_min_capacity" {
  type    = number
  default = 3
}

variable "node_k8s_labels" {
  type    = string
  default = "worker"
}

variable "jumpbox_ami_id" {
  type    = string
  default = "ami-088c29f1c294f7971"
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
  default = []
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
  default     = "logs-elb-us-west-2"
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

variable "web_external_lb_dns_value" {
  type    = string
  default = ""
}

variable "course1_external_lb_dns_value" {
  type    = string
  default = ""
}

variable "course1_external_lb_dns" {
  type    = string
  default = ""
}

variable "enable_s3_export_role" {
  type    = bool
  default = true
}

variable "course1_internal_lb_dns_value" {
  type    = string
  default = ""
}

variable "eks_internal_lb_dns_value" {
  type    = string
  default = ""
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "create_alb_ingress_controller" {
  type    = bool
  default = false
}

variable "db_instance_class_course1" {
  default = "db.t3.micro"
}

variable "snapshot_identifier" {
  type    = string
  default = ""
}

variable "snapshot_identifier_course1" {
  type    = string
  default = ""
}

variable "kms_key_id" {
  type    = string
  default = ""
}
variable "storage_encrypted" {
  type    = bool
  default = true
}
variable "s3_bucket_names" {
  type    = list(string)
  default = [""]
}

variable "s3_bucket_names_hub" {
  type    = list(string)
  default = ["evaluation-reports"]
}

variable "ecs_strongdm_sg_id" {
  type    = string
  default = ""
}

variable "db_instance_class_api" {
  default = "db.t3.small"
}

variable "db_instance_class_api_course1" {
  default = "db.t4g.micro"
}

variable "create_alb_ingress_dns" {
  type    = bool
  default = false
}

variable "redis_instance_count" {
  description = "Number of redis nodes"
  type        = string
  default     = 0
}

variable "enable_internal_lb" {
  description = "Boolean to enable/create the internal load balancer for the forward proxy"
  type        = string
  default     = true
}

variable "list_of_cidrs_for_course1_internal_lb" {
  type    = list(any)
  default = [""]
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

variable "allow_test_hub" {
  type    = bool
  default = false
}

variable "allow_stage_hub" {
  type    = bool
  default = false
}

variable "replicate_source_db" {
  type    = string
  default = ""
}

############ hub related variables ############
variable "hub_eks_desired_capacity" {
  type    = number
  default = 3
}

variable "hub_eks_max_capacity" {
  type    = number
  default = 5
}

variable "hub_eks_min_capacity" {
  type    = number
  default = 1
}

variable "hub_eks_instance_types" {
  type    = list(string)
  default = ["m5a.large", "m5.large", "m4.large"]
}

variable "hub_node_k8s_labels" {
  type    = string
  default = "hub-worker"
}

variable "course1_services_subnet_cidr_list" {
  type        = list(any)
  default     = [""]
  description = "Subnets sc-course1-*-apps-services-apse1-*"
}

variable "db_iam_feature_name" {
  type    = string
  default = "s3Import"
}

variable "sqlserver_backup_restore_iam_role_arn" {
  type    = string
  default = """
}

variable "api_list_iam_roles_service_account_hub" {
  description = "List of service accounts"
  type        = list(string)
  default     = ["course1-dev-hub-apps-common", "alb-ingress-controller"]
}

variable "eks_internal_lb_dns_value_hub" {
  type    = string
  default = ""
}

variable "eks_internal_lb_dns_hub" {
  type    = string
  default = ""
}

variable "course1_external_lb_dns_value_hub" {
  type    = string
  default = ""
}

variable "course1_external_lb_dns_hub" {
  type    = string
  default = ""
}

variable "create_alb_ingress_controller_hub" {
  type    = bool
  default = true
}

variable "external_web_lb_hub" {
  type    = string
  default = ""
}

variable "external_web_lb_value_hub" {
  type    = string
  default = ""
}

################################################
variable "region_short" {
  type    = string
  default = "usw2"
}

variable "apse1_domain_name" {
  type    = string
  default = ""
}

variable "enable_external_lb" {
  description = "Boolean to enable/create the external load balancer, exposing course1 to the Internet"
  type        = string
  default     = true
}

variable "create_course1_iam_role" {
  description = "Boolean to enable/create the IAM role for course1 cluster"
  type        = bool
  default     = true
}

variable "create_jumpbox_iam_role" {
  type    = bool
  default = true
}

variable "meet_app_external_lb_dns" {
  type    = string
  default = ""
}

variable "meet_app_external_lb_dns_value" {
  type    = string
  default = ""
}

############################

variable "whitelist_cloudfront_ips" {
  description = "List of CIDRs to whitelist for CloudFront"
  type        = map(any)
  default = {
    
  }
}

variable "whitelist_cloudfront_ips_1" {
  description = "List of CIDRs to whitelist for CloudFront"
  type        = map(any)
  default = {
   
  }
}

variable "associate_lb_to_wafv2" {
  type    = bool
  default = true
}

variable "create_local_vpc" {
  type    = bool
  default = true
}

variable "enable_option_group" {
  type    = bool
  default = false
}

variable "add_iam_role_to_db" {
  type    = bool
  default = true
}

variable "db_instance_count" {
  description = "Number of database instances (0 to leverage an existing db)"
  type        = string
  default     = 1
}

variable "option_prefix" {
  type    = string
  default = "db-options"
}

variable "db_options_engine_version" {
  type    = string
  default = "15.00"
}

variable "enable_extra_rds" {
  description = "Boolean to enable extra RDS server"
  type        = string
  default     = true
}

variable "db_final_snapshot_identifier" {
  description = "The final snapshot name of the RDS instance when it gets destroyed"
  type        = string
  default     = ""
}

variable "license_model" {
  type    = string
  default = "postgresql-license"
}

variable "monitoring_interval" {
  type    = number
  default = 0
}
variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = []
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "monitoring_role_arn" {
  type    = string
  default = ""
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version_lab" {
  description = "Database engine version"
  type        = string
  default     = "14.5"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_storage_size" {
  description = "Size of the database storage in Gigabytes"
  type        = string
  default     = 100 # 100 is the recommended AWS minimum
}

variable "max_autoscaled_storage" {
  type    = number
  default = 0
}

variable "ipset_ipv4" {
  type        = list(any)
  default     = []
  description = "List of IPV4 addresses to allow from WAF"
}