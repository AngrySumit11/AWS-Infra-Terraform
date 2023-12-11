variable "elb_account_id" {
  type        = string
  description = "ELB account id specific to region"
  default     = ""
}

variable "logs_bucket_name" {
  type        = string
  description = "Name of the bucket"
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account id for course1 Non Prod"
  default     = ""
}

variable "domain_name" {
  description = "Domain name for ssl certificate"
  type        = string
  default     = ""
}

variable "account_alias" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
  default     = "course1-non-prod"
}

variable "create_route53_zone" {
  description = "Boolean to specify whether to create route53 hosted zone or not"
  type        = bool
  default     = false
}

variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
}

variable "environment" {
  type    = string
  default = "non-prod"
}

variable "common_tags" {
  type = map(string)
  default = {
   
}

variable "zone_id" {
  type    = string
  default = ""
}

variable "s3_bucket_names" {
  type    = list(string)
  default = ["sdcrm-mail", "mail-journal"]
}

variable "gh_oidc_url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  type        = string
  default     = "token.actions.githubusercontent.com"
}

variable "client_id_list" {
  description = " A list of client IDs to register with OIDC"
  type        = list(any)
  default     = ["sts.amazonaws.com"]
}

variable "thumbprint_list" {
  description = "A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)"
  type        = list(any)
  default     = [""]
}

variable "owner" {
  type        = string
  description = "Name or email id of the owner of the resource"
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable description {
  type    = string
  default = "KMS key for database encryption"
}

variable key_spec {
  type    = string
  default = "SYMMETRIC_DEFAULT"
}

variable enabled {
  type    = string
  default = "true"
}

variable rotation_enabled {
  type    = string
  default = "false"
}
