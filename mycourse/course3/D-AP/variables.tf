locals {
  cluster_name     = "${var.primary_name}-${var.environment}-${var.region_short}-apps"
  course1_cluster_name = "${var.primary_name}-${var.environment}-${var.region_short}-course1-apps"
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
  description = "Env identifier as per gitcourse1 branch"
  type        = string
  default     = "-develop"
}

variable "eks_instance_types" {
  type    = list(string)
  default = ["c5a.xlarge", "c5.xlarge", "c4.xlarge"]
}

variable "eks_desired_capacity" {
  type    = number
  default = 4
}

variable "eks_max_capacity" {
  type    = number
  default = 6
}

variable "eks_min_capacity" {
  type    = number
  default = 1
}

variable "node_k8s_labels" {
  type    = string
  default = "worker"
}

variable "jumpbox_ami_id" {
  type    = string
  default = "ami-0df96d272a8f2ce4c"
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
  default = [""]
}

variable "environment" {
  description = "Env name"
  type        = string
  default     = "dev"
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
  default     = "course1-non-prod-apse1"
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
  default     = "logs-elb-ap-southeast-1"
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
  default = false
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

variable "s3_bucket_names_course1" {
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
  default = false
}

variable "allow_stage" {
  type    = bool
  default = false
}

variable "allow_test_course1" {
  type    = bool
  default = false
}

variable "allow_stage_course1" {
  type    = bool
  default = false
}

variable "replicate_source_db" {
  type    = string
  default = ""
}

############ course1 related variables ############
variable "course1_eks_desired_capacity" {
  type    = number
  default = 2
}

variable "course1_eks_max_capacity" {
  type    = number
  default = 5
}

variable "course1_eks_min_capacity" {
  type    = number
  default = 1
}

variable "course1_eks_instance_types" {
  type    = list(string)
  default = ["m5a.large", "m5.large", "m4.large"]
}

variable "course1_node_k8s_labels" {
  type    = string
  default = "course1-worker"
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
  default = ""
}

variable "api_list_iam_roles_service_account_course1" {
  description = "List of service accounts"
  type        = list(string)
  default     = ["course1-dev-course1-apps-common", "alb-ingress-controller"]
}

variable "eks_internal_lb_dns_value_course1" {
  type    = string
  default = ""
}

variable "eks_internal_lb_dns_course1" {
  type    = string
  default = ""
}

variable "course1_external_lb_dns_value_course1" {
  type    = string
  default = "course1-nonprod.apps.course1.net"
}

variable "course1_external_lb_dns_course1" {
  type    = string
  default = ""
}

variable "create_alb_ingress_controller_course1" {
  type    = bool
  default = true
}

variable "external_web_lb_course1" {
  type    = string
  default = ""
}

variable "external_web_lb_value_course1" {
  type    = string
  default = ""
}

################################################
variable "region_short" {
  type    = string
  default = "apse1"
}

variable "enable_external_lb" {
  description = "Boolean to enable/create the external load balancer, exposing course1 to the Internet"
  type        = string
  default     = true
}

variable "create_course1_iam_role" {
  description = "Boolean to enable/create the IAM role for course1 cluster"
  type        = bool
  default     = false
}

variable "create_jumpbox_iam_role" {
  type    = bool
  default = false
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
  default = false
}
