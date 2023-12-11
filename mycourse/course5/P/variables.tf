locals {
  cluster_name     = "${var.primary_name}-${var.environment}-apps"
}

variable "account_id" {
  description = "AWS Account Id"
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


variable "env_identifier" {
  description = "Env identifier as per github branch"
  type        = string
  default     = "-poc"
}

variable "eks_instance_types" {
  type    = list(string)
  default = ["t3.small", "t2.small"]
}

variable "eks_desired_capacity" {
  type    = number
  default = 1
}

variable "eks_max_capacity" {
  type    = number
  default = 2
}

variable "eks_min_capacity" {
  type    = number
  default = 1
}

variable "node_k8s_labels" {
  type    = string
  default = "worker"
}


variable "api_list_iam_roles" {
  description = "List of API names which needs iam access"
  type        = list(string)
  default     = ["common"]
}

variable "api_list_iam_roles_service_account" {
  description = "List of service accounts"
  type        = list(string)
  default     = ["poc-apps-common"]
}

variable "api_list_iam_roles_namespaces" {
  description = "List of namespaces"
  type        = list(string)
  default     = ["default"]
}

/*
variable "environment" {
  description = "Env name"
  type        = string
  default     = "poc"
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
  default     = "poc-vpc"
}

variable "vpc_id" {
  type    = string
  default = "vpc-062d5dbc393cf2d36"
}

variable "vpc_cidr" {
  type    = string
  default = "10.221.0.0/16"
}
*/
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


variable "ec2_key_name" {
  description = "Public ssh key name"
  type        = string
  default     = "eks-poc"
}

variable "namespace" {
  type    = string
  default = "default"
}

################################################
variable "region_short" {
  type    = string
  default = "usw2"
}

############### RDS MS SQL #########
variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1" ## Please update this field based on your requirement
}

variable "environment" {
  description = "Env name"
  type        = string
  default     = "poc" ## Please update this field based on your requirement
}

// The allocated storage in gigabytes.
variable "rds_allocated_storage" {
  type        = string  
  default     = "250" ## Please update this field based on your requirement
}

// The instance type of the RDS instance.
variable "rds_instance_class" {
  type        = string  
  default     = "db.t3.small" ## Please update this field based on your requirement
}

// Specifies if the RDS instance is multi-AZ.
variable "rds_multi_az" {
  type    = string  
  default = "false" ## Please update this field based on your requirement
}

// A list of VPC subnet identifiers.
variable "vpc_subnet_ids" {
  type    = list(string)
  default =[""] ## Please update this field based on your requirement
}

// The VPC identifier where security groups are going to be applied.
variable "vpc_id" {
  type    = string
  default = "" ## Please update this field based on your requirement
}

// List of CIDR blocks that will be granted to access to mssql instance.
variable "vpc_cidr_blocks" {
  type    = string
  default = "" ## Please update this field based on your requirement
}

// Determines whether a final DB snapshot is created before the DB instance is deleted.
variable "skip_final_snapshot" {
  type    = string
  default = "true" ## Please update this field based on your requirement
}

// DB snapshot name
variable "snapshot_identifier" {
  type    = string
  default = "admin-prod-poc" ## Please update this field based on your requirement
}

// DB Parameter group version
variable "db_family" {
  description = "Database parameter group family"
  type        = string
  default     = "sqlserver-ex-15.0"
}

// DB Engine Version
variable "rds_engine_version" {
  type        = string  
  default     = "15.00.4312.2.v1" ## Please update this field based on your requirement
}

// DB Engine Type
variable "engine_type" {
  type        = string  
  default     = "sqlserver-ex" ## Please update this field based on your requirement
}

#############