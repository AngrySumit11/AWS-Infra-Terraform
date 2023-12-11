variable "primary_name" {
  description = "Initials for any service"
  type        = string
}

variable "enable_cache" {
  description = "Boolean to enable Cache"
  type        = string
  default     = true
}


variable "environment" {
  description = "Resource environment tag (i.e. dev, stage, prod)"
  type        = string
}

variable "cache_engine" {
  default = "redis"
  type    = string
}

variable "cache_engine_version" {
  description = "Cache engine version"
  type        = string
  default     = "5.0.6"
}

variable "cache_instance_type" {
  description = "Database instance class"
  type        = string
  default     = "cache.t3.small"
}

variable "cache_instance_count" {
  description = "Number of database instances (0 to leverage an existing db)"
  type        = string
  default     = 1
}

variable "cache_family" {
  description = "Database parameter group family"
  type        = string
  default     = "redis5.0"
}

# Required tags
variable "description" {
  description = "Resource description tag"
  type        = string
  default     = "ElastiCache Cluster"
}

variable "cache_subnet_ids" {
  description = "List of subnet ids"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group ids"
  type        = list(string)
}

variable "snapshot_arns" {
  description = "List of ARN of s3 containing rdb files"
  type        = list(string)
  default     = []
}


variable "snapshot_retention_limit" {
  description = "No of days for snapshot retention"
  type        = number
  default     = 3
}

variable "encryption_at_rest" {
  description = "Elastic cache encryption at rest status"
  type        = bool
  default     = false
}

variable "key_id" {
  description = "Elastic cache encryption at rest status"
  type        = string
}
