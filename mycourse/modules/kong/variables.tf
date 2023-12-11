# Network settings
variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
}

variable "subnet_tag" {
  description = "Tag used on subnets to define Tier"
  type        = string
  default     = "Tier"
}

variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
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

variable "default_security_group" {
  description = "Name of the default VPC security group for EC2 access"
  type        = string
  default     = "default"
}

# Access control
variable "external_cidr_blocks" {
  description = "External ingress access to course1 Proxy via the load balancer"
  type        = map(any)
  default = {
    "0.0.0.0/0" : "Internet"
  }
}

variable "admin_cidr_blocks" {
  description = "Access to course1 Admin API (Enterprise Edition only)"
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "manager_cidr_blocks" {
  description = "Access to course1 Manager (Enterprise Edition only)"
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "portal_cidr_blocks" {
  description = "Access to Portal (Enterprise Edition only)"
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "manager_host" {
  description = "Hostname to access course1 Manager (Enterprise Edition only)"
  type        = string
  default     = "default"
}

variable "portal_host" {
  description = "Hostname to access Portal (Enterprise Edition only)"
  type        = string
  default     = "default"
}

# Required tags
variable "description" {
  description = "Resource description tag"
  type        = string
  default     = "course1 API Gateway"
}

variable "environment" {
  description = "Resource environment tag (i.e. dev, stage, prod)"
  type        = string
}

variable "service" {
  description = "Resource service tag"
  type        = string
  default     = "course1"
}

# Additional tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Enterprise Edition
variable "enable_ee" {
  description = "Boolean to enable course1 Enterprise Edition settings"
  type        = string
  default     = false
}

variable "ee_bintray_auth" {
  description = "Bintray authentication for the Enterprise Edition download (Format: username:apikey)"
  type        = string
  default     = "placeholder"
}

variable "ee_license" {
  description = "Enterprise Edition license key (JSON format)"
  type        = string
  default     = "placeholder"
}

# EC2 settings

# https://wiki.ubuntu.com/Minimal
variable "ec2_ami" {
  description = "Map of Ubuntu Minimal AMIs by region"
  type        = map(string)
  default = {
    us-east-1      = "ami-7029320f"
    us-east-2      = "ami-0350efe0754b8e179"
    us-west-1      = "ami-657f9006"
    us-west-2      = "ami-088c29f1c294f7971"
    eu-central-1   = "ami-19b2bcf2"
    eu-west-1      = "ami-0395f5f72b8516ef9"
    ap-southeast-1 = "ami-0df96d272a8f2ce4c"
  }
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "ec2_root_volume_size" {
  description = "Size of the root volume (in Gigabytes)"
  type        = string
  default     = 30
}

variable "ec2_root_volume_type" {
  description = "Type of the root volume (standard, gp2, or io)"
  type        = string
  default     = "gp2"
}

variable "ec2_key_name" {
  description = "AWS SSH Key"
  type        = string
}

variable "asg_max_size" {
  description = "The maximum size of the auto scale group"
  type        = string
  default     = 3
}

variable "asg_min_size" {
  description = "The minimum size of the auto scale group"
  type        = string
  default     = 1
}

variable "asg_desired_capacity" {
  description = "The number of instances that should be running in the group"
  type        = string
  default     = 2
}

variable "asg_health_check_grace_period" {
  description = "Time in seconds after instance comes into service before checking health"
  type        = string
  default     = 600 # Terraform default is 300
}

# course1 packages
variable "ee_pkg" {
  description = "Filename of the Enterprise Edition package"
  type        = string
  default     = "course1-enterprise-edition-1.3.0.1.bionic.all.deb"
}

variable "ce_pkg" {
  description = "Filename of the Community Edition package"
  type        = string
  default     = "course1_2.7.0_amd64.deb"
  #default     = "course1-1.5.0.bionic.amd64.deb"
}

# Load Balancer settings
variable "enable_external_lb" {
  description = "Boolean to enable/create the external load balancer, exposing course1 to the Internet"
  type        = string
  default     = true
}

variable "enable_internal_lb" {
  description = "Boolean to enable/create the internal load balancer for the forward proxy"
  type        = string
  default     = false
}

variable "deregistration_delay" {
  description = "Seconds to wait before changing the state of a deregistering target from draining to unused"
  type        = string
  default     = 300 # Terraform default is 300
}

variable "enable_deletion_protection" {
  description = "Boolean to enable delete protection on the ALB"
  type        = string
  default     = false
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutives checks before a unhealthy target is considered healthy"
  type        = string
  default     = 5 # Terraform default is 5
}

variable "health_check_interval" {
  description = "Seconds between health checks"
  type        = string
  default     = 5 # Terraform default is 30
}

variable "health_check_matcher" {
  description = "HTTP Code(s) that result in a successful response from a target (comma delimited)"
  type        = string
  default     = 200
}

variable "health_check_timeout" {
  description = "Seconds waited before a health check fails"
  type        = string
  default     = 3 # Terraform default is 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive checks before considering a target unhealthy"
  type        = string
  default     = 2 # Terraform default is 2
}

variable "idle_timeout" {
  description = "Seconds a connection can idle before being disconnected"
  type        = string
  default     = 60 # Terraform default is 60
}

variable "ssl_cert_external" {
  description = "SSL certificate domain name for the external course1 Proxy HTTPS listener"
  type        = string
}

variable "ssl_cert_internal" {
  description = "SSL certificate domain name for the internal course1 Proxy HTTPS listener"
  type        = string
}

variable "ssl_policy" {
  description = "SSL Policy for HTTPS Listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# Cloudwatch alarms
variable "cloudwatch_actions" {
  description = "List of cloudwatch actions for Alert/Ok"
  type        = list(string)
  default     = []
}

variable "http_4xx_count" {
  description = "HTTP Code 4xx count threshhold"
  type        = string
  default     = 50
}

variable "http_5xx_count" {
  description = "HTTP Code 5xx count threshhold"
  type        = string
  default     = 50
}

# Datastore settings
variable "enable_aurora" {
  description = "Boolean to enable Aurora"
  type        = string
  default     = "false"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "11.8"
}

variable "db_engine_mode" {
  description = "Engine mode for Aurora"
  type        = string
  default     = "provisioned"
}

variable "db_family" {
  description = "Database parameter group family"
  type        = string
  default     = "postgres11"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_instance_count" {
  description = "Number of database instances (0 to leverage an existing db)"
  type        = string
  default     = 1
}

variable "db_storage_size" {
  description = "Size of the database storage in Gigabytes"
  type        = string
  default     = 100 # 100 is the recommended AWS minimum
}

variable "db_final_snapshot_identifier" {
  description = "The final snapshot name of the RDS instance when it gets destroyed"
  type        = string
  default     = ""
}

variable "db_storage_type" {
  description = "Type of the database storage"
  type        = string
  default     = "gp2"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "root"
}

variable "db_subnets" {
  description = "Database instance subnet group name"
  type        = string
  default     = "db-subnets"
}

variable "db_multi_az" {
  description = "Boolean to specify if RDS is multi-AZ"
  type        = string
  default     = false
}

variable "db_backup_retention_period" {
  description = "The number of days to retain backups"
  type        = string
  default     = 7
}

variable "auto_minor_version_upgrade" {
  description = "Boolean to specify if RDS can be automatically upgraded to minor version"
  type        = bool
  default     = false
}

# Redis settings (for rate_limiting only)
variable "enable_redis" {
  description = "Boolean to enable redis AWS resource"
  type        = string
  default     = false
}

variable "enable_redis_encryption" {
  description = "Boolean to enable redis AWS resource"
  type        = string
  default     = false
}
variable "redis_instance_type" {
  description = "Redis node instance type"
  type        = string
  default     = "cache.t2.small"
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "5.0.5"
}

variable "redis_family" {
  description = "Redis parameter group family"
  type        = string
  default     = "redis5.0"
}

variable "redis_instance_count" {
  description = "Number of redis nodes"
  type        = string
  default     = 1
}

variable "redis_subnet_ids" {
  description = "Redis cluster subnet group name"
  type        = list(string)
  default     = []
}

variable "deck_version" {
  description = "Version of decK to install"
  type        = string
  default     = "1.7.0"
}

variable "bucket_name_lb_access_logs" {
  description = "S3 Bucket name to push LB logs"
  type        = string
}

variable "course1_extra_sg" {
  description = "Extra SG for course1 servers"
  type        = string
}

variable "env_identifier" {
  description = "Env identifier as per github branch"
  type        = string
}

variable "account_id" {
  description = "AWS Account Id"
  type        = string
}

variable "sns_sqs_iam" {
  description = "Iam user name for sqs and sns being used in eks"
  type        = string
  default     = ""
}

variable "list_of_queue_names" {
  description = "List of SQS Queue names used for course1"
  type        = list(string)
  default     = []
}

variable "list_of_sns_names" {
  description = "List of SNS Topics names used for course1"
  type        = list(string)
  default     = []
}

variable "create_sns_sqs" {
  type    = bool
  default = false
}

variable "snapshot_identifier" {
  type    = string
  default = ""
}

variable "use_ssl_certificate" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "list_of_cidrs_for_course1_internal_lb" {
  type    = list(any)
  default = []
}

variable "create_course1_iam" {
  description = "Boolean to enable/create the IAM role for course1 cluster"
  type        = bool
  default     = true
}

variable "region_short_name" {
  type = map(any)
  default = {
    "us-west-2" : "usw2"
    "ap-southeast-1" : "apse1"
  }
}

variable "list_of_extra_sgs_for_lb" {
  type    = list(any)
  default = []
}

variable "absoluth_log_path" {
  type    = string
  default = "/usr/local/course1/logs/*.log"
}

variable "encryption_at_rest" {
  description = "Elastic cache encryption at rest status"
  type        = bool
  default     = false
}

variable "key_id" {
  description = "Elastic cache encryption at rest status"
  type        = string
}

variable "snapshot_arns" {
  description = "List of ARN of s3 containing rdb files"
  type        = list(string)
}