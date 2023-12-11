locals {
  cluster_name     = "${var.primary_name}-${var.environment}-apps"
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


variable "env_identifier" {
  description = "Env identifier as per github branch"
  type        = string
  default     = "-sandbox"
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
  default     = ["course1-sandbox-apps-common"]
}

variable "api_list_iam_roles_namespaces" {
  description = "List of namespaces"
  type        = list(string)
  default     = ["default", "kube-system"]
}


variable "environment" {
  description = "Env name"
  type        = string
  default     = "sandbox"
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
  default     = "course1-non-prod"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0b4f21d2dc0c14f87"
}

variable "vpc_cidr" {
  type    = string
  default = "10.219.0.0/16"
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


variable "ec2_key_name" {
  description = "Public ssh key name"
  type        = string
  default     = "default-keypair"
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