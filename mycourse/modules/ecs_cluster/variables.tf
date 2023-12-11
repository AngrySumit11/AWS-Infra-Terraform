variable "name" {
  type        = string
  description = "Name of the cluster"
}

variable "secrets" {
  type        = list(string)
  default     = []
  description = "List of kms secrets ARNs"
}

variable "ecr_repos" {
  type        = list(string)
  default     = []
  description = "List of ECR Repo ARNs"
}

variable "create_task_role" {
  type        = bool
  default     = true
  description = "Boolean to decide whether Task Execution Role needs to be created or not"
}

variable "task_role_name" {
  type        = string
  default     = ""
  description = "Task Role Name to be assumed by containers"
}

variable "cloudwatch_log_retention_days" {
  type        = number
  default     = 7
  description = "Log retention in days for Cloud Watch Logs"
}

variable "owner" {
  type        = string
  default     = ""
  description = "Name or email id of the owner of the resource"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Name of the environment e.g dev, test, stage, prod"
}

variable "vpc_id" {
  type        = string
  description = "VPC Id"
}
