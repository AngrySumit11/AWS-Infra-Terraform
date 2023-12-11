variable "primary_name" {
  description = "Initials for any service"
  type        = string
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

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "11.10"
}

variable "db_family" {
  description = "Database parameter group family"
  type        = string
  default     = "postgres14"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.m5.xlarge"
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

variable "snapshot_identifier" {
  type    = string
  default = ""
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "root"
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

variable "subnet_prefix" {
  type    = string
  default = "db-subnets"
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "enable_extra_rds" {
  description = "Boolean to enable extra RDS server"
  type        = string
  default     = false
}

variable "rds_security_groups_list" {
  description = "List of security group list ids"
  type        = list(string)
}

variable "subnet_ids_list" {
  description = "List of subnet ids"
  type        = list(string)
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "max_autoscaled_storage" {
  type    = number
  default = 0
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "enable_option_group" {
  type    = bool
  default = false
}

variable "option_prefix" {
  type    = string
  default = "db-options"
}

variable "db_options_engine_version" {
  type    = string
  default = "15.00"
}

variable "license_model" {
  type    = string
  default = "postgresql-license"
}

variable "monitoring_interval" {
  type    = number
  default = 0
}
variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = []
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "storage_encrypted" {
  type    = bool
  default = false
}

variable "monitoring_role_arn" {
  type    = string
  default = ""
}

variable "sqlserver_backup_restore_iam_role_arn" {
  type    = string
  default = "arn:aws:iam::accountid:role/rds-monitoring-role"
}

variable "add_iam_role_to_db" {
  type    = bool
  default = false
}

variable "db_iam_feature_name" {
  type    = string
  default = "S3_INTEGRATION"
}

variable "replicate_source_db" {
  type    = string
  default = ""
}

variable "auto_minor_version_upgrade" {
  type = bool
  default = false
}
