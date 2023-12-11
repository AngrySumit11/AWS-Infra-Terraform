variable "elb_account_id" {
  type        = string
  description = "ELB account id specific to region"
  default     = ""
}

variable "logs_bucket_name" {
  type        = string
  description = "Name of the bucket"
  default     = "non-prod-logs"
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
  default     = "course1-non-prod"
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
  default     = "course1-non-prod"
}

variable "create_route53_zone" {
  description = "Boolean to specify whether to create route53 hosted zone or not"
  type        = bool
  default     = true
}

variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "environment_common" {
  type    = string
  default = "non-prod"
}

variable "instance_type_windows" {
  type    = string
  default = "t3.medium"
}

variable "ebs_optimized_windows" {
  type    = bool
  default = true
}

variable "source_sg_for_rdp_ssh" {
  description = "Source security groups for rdp"
  type        = string
  default     = ""
}

variable "instance_type_linux" {
  type    = string
  default = "t3.small"
}

variable "ec2_ami_id_linux" {
  type    = string
  default = "ami-0286f6a5ddc5642f6"
}

variable "common_tags" {
  type = map(string)
  default = {
   
  }
}

variable "zone_id" {
  type    = string
  default = "Z01099343MWSE69XVZ1TT"
}

variable "s3_bucket_names" {
  type    = list(string)
  default = [""]
}

variable "common_ses_name" {
  type    = string
  default = "globalapps-chinaprlite"
}

variable "list_of_iam_policy_arn" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

variable "s3_allow_userIds" {
  type = list(any)
  default = [
    "accountid",
    "AROA2E7KFMOMYGRNU4DEN:*",
    "AROA2E7KFMOMS25B64IKP:*",
    "AROA2E7KFMOMRT3VAO6WL:*",
    "AROA2E7KFMOMQKFOFTXBR:*",
    "AROA2E7KFMOMWEXXCF5PH:*",
    "AROA4BKQ4WIFGDGXHELHC:*"
  ]
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

variable "server_name" {
  description = "Key identifier for server name"
  type        = string
  default     = ""
}

variable "red_canary_ecr_repo" {
  description = "red canary ecr repo name"
  type        = string
  default     = ""
}

variable "ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      source_security_group_id  = string
      description = string
    }))
    default     = [
        {
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          source_security_group_id = ""
          description = "course1-test-course1-external-lb"
        },
        {
          from_port   = 8001
          to_port     = 8001
          protocol    = "tcp"
          source_security_group_id = ""
          description = "course1-test-course1-external-lb"
        },
    ]
}

variable description {
  type    = string
  default = "KMS key for database encryption"
}

variable key_spec {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable enabled {
  description = "Specifies whether the key is enabled"
  type        = string
  default     = "true"
}

variable rotation_enabled {
  description = "Specifies whether key rotation is enabled"
  type        = string
  default     = "false"
}

variable "backup_iam_role_arn" {
  type        = string
  description = "AWS IAM role for BackUp Service"
  default = ""
}
