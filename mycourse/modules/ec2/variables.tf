variable "primary_name" {
  description = "Initials for any service"
  type        = string
}

variable "environment" {
  description = "Resource environment tag (i.e. dev, stage, prod)"
  type        = string
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
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

variable "ec2_ami_id" {
  description = "AMI Id for EC2"
  type        = string
}

variable "ec2_key_pair" {
  description = "Key pair for EC2"
  type        = string
  default     = ""
}

variable "server_name" {
  description = "Key identifier for server name"
  type        = string
}

variable "list_of_cidr_for_ssh" {
  description = "List of cidr blocks for ssh"
  type        = list(string)
  default     = []
}

variable "category" {
  type    = string
  default = "services"
}

variable "source_sg_for_ssh" {
  description = "Source security groups for ssh"
  type        = string
  default     = ""
}

variable "list_of_cidr_for_rdp" {
  description = "List of cidr blocks for rdp"
  type        = list(string)
  default     = []
}

variable "source_sg_for_rdp" {
  description = "Source security groups for rdp"
  type        = string
  default     = ""
}

variable "list_of_iam_policy_arn" {
  description = "Arn of the policy to attach"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "source_sg_for_http" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "vpc_security_group_ids" {
  type    = list(any)
  default = []
}

variable "volume_size" {
  type    = number
  default = 30
}

variable "name_tag" {
  type    = string
  default = ""
}
variable "enable_extra_ebs" {
  type    = bool
  default = false
}

variable "extra_ebs_size" {
  type    = number
  default = 50
}
