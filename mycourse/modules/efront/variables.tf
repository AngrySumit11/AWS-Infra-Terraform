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

variable "ec2_ami_id_linux" {
  description = "AMI Id for EC2"
  type        = string
  default     = ""
}

variable "ec2_ami_id_windows" {
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

variable "sg_for_ssh" {
  description = "sg id for ssh"
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

variable "create_iam_role" {
  type    = bool
  default = false
}

variable "instance_type_linux" {
  type    = string
  default = "t3.small"
}

variable "instance_type_windows" {
  type    = string
  default = "t3.small"
}

variable "s3_bucket_names" {
  type    = list(string)
  default = []
}

variable "common_tags" {
  type = map(string)
}

variable "linux_count" {
  type    = number
  default = 0
}

variable "windows_count" {
  type    = number
  default = 0
}

variable "ebs_optimized_linux" {
  type    = bool
  default = false
}

variable "ebs_optimized_windows" {
  type    = bool
  default = false
}
