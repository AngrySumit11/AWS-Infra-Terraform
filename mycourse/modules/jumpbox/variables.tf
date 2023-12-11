variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
}

variable "app_name" {
  type    = string
  default = "jumpbox"
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

variable "category" {
  description = "Subnet tag"
  type        = string
  default     = "services"
}

variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpguBeewpX27NOIj7K5XOSM0uZQ6ZynmwrWBYDB726hjSLNuTbCoroMIxRZmPH4GRxl0aD1I610lc2hayYvyk0/WYn1Yn6DlPT4JpHuARVwYicidz5PyDwRnPJdd/9GwAId5my1+RIjVmdSI03qmMkt+fN6zQokPgtFaPZuPzJd6AgNd/4QcmDBXPt9R2zEytQWGZufuEzTMi21qgHAvsPrLTJtfPiJELN6MY6mkg9xze7dL7rD0ZKpiHZigPblfT9cYLt3yqUVBEDw8lWjaz6WkthdFGhTU/+Hs7Fdri1bxhx/e/DES2Wl0JdbG2hyPDEuagdsouevOqxW6o8NNGf"
}

variable "key_pair_prefix" {
  type    = string
  default = "jumpbox-keypair"
}
variable "list_of_iam_policy_arn" {
  description = "Arn of the policy to attach"
  type        = list(string)
  default     = []
}

variable "ami_id" {
  type    = string
  default = "ami-000892e0bc49a951d"
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "create_iam_role" {
  type    = bool
  default = true
}

variable "volume_size" {
  type    = string
  default = 20
}