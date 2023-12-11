# Datastore settings
variable "primary_name" {
  description = "Initials for any service"
  type        = string
}

variable "environment" {
  description = "Env name"
  type        = string
}

variable "enable_aurora" {
  description = "Boolean to enable Aurora"
  type        = string
  default     = "false"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "11.8"
}

variable "db_engine_mode" {
  description = "Engine mode for Aurora"
  type        = string
  default     = "provisioned"
}

variable "db_family" {
  description = "Database parameter group family"
  type        = string
  default     = "postgres14"
}

variable "db_parameter_group_family" {
  description = "Database parameter group family"
  type        = string
  default     = "aurora-postgresql14"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.medium"
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

variable "db_storage_type" {
  description = "Type of the database storage"
  type        = string
  default     = "gp2"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "root"
}

variable "db_subnets" {
  description = "Database instance subnet group name"
  type        = string
  default     = "db-subnets"
}

variable "db_multi_az" {
  description = "Boolean to specify if RDS is multi-AZ"
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "The number of days to retain backups"
  type        = string
  default     = "7"
}



variable "subnet_prefix" {
  type    = string
  default = "db-subnets"
}


variable "rds_security_groups_list" {
  description = "List of security group list ids"
  type        = list(string)
}

variable "subnet_ids_list" {
  description = "List of subnet ids"
  type        = list(string)
}


variable "service" {
  description = "Resource service tag"
  type        = string
  default     = "course1"
}

variable "description" {
  description = "Resource description tag"
  type        = string
  default     = "course1 API Gateway"
}


variable "database_name" {
  description = "Database Name"
  type        = string

}

variable "storage_encrypted" {
  type    = bool
  default = false
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "snapshot_identifier" {
  type    = string
  default = ""
}
