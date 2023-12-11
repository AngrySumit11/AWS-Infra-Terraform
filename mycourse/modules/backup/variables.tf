variable "primary_name" {
  description = "Initials for any service"
  type        = string
}

variable "environment" {
  description = "Resource environment tag (i.e. dev, stage, prod)"
  type        = string
}

variable "server_name" {
  description = "Key identifier for server name"
  type        = string
}

variable "rule" {
  description = "Set of rules described in backup plan"
  type        = any
  default     = []
}

variable "target_backup_server_tag_key" {
  description = "Tag key of the target backup server"
  type        = string
}

variable "target_backup_server_tag_value" {
  description = "Tag vaule of the target backup server"
  type        = string
}


variable "aws_account_id" {
  type        = string
  description = "AWS Account id for course1 Non Prod and Prod"
}

variable "backup_iam_role_arn" {
  type        = string
  description = "AWS IAM role for BackUp Service"
}