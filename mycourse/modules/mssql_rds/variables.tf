
############### RDS MS SQL #########
variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "" ## Please update this field based on your requirement
}

variable "environment" {
  description = "Env name"
  type        = string
  default     = "" ## Please update this field based on your requirement
}

// The allocated storage in gigabytes.
variable "rds_allocated_storage" {
  type        = string  
  default     = "250" ## Please update this field based on your requirement
}

// The instance type of the RDS instance.
variable "rds_instance_class" {
  type        = string  
  default     = "db.t3.small" ## Please update this field based on your requirement
}

variable "rds_engine_version" {
  type        = string  
  default     = "15.00.4312.2.v1" ## Please update this field based on your requirement
}

variable "engine_type" {
  type        = string  
  default     = "sqlserver-ex" ## Please update this field based on your requirement
}

// Specifies if the RDS instance is multi-AZ.
variable "rds_multi_az" {
  type    = string  
  default = "false" ## Please update this field based on your requirement
}

// Username for the administrator DB user.
//variable "mssql_admin_username" {} ## Please update this field based on your requirement

// Password for the administrator DB user.
//variable "mssql_admin_password" {} ## Please update this field based on your requirement

// A list of VPC subnet identifiers.
variable "vpc_subnet_ids" {
  type    = list(string)
  default =[] ## Please update this field based on your requirement
}

// The VPC identifier where security groups are going to be applied.
variable "vpc_id" {
  type    = string
  default = "" ## Please update this field based on your requirement
}

// List of CIDR blocks that will be granted to access to mssql instance.
variable "vpc_cidr_blocks" {
  type    = string
  default = "" ## Please update this field based on your requirement
}

// Determines whether a final DB snapshot is created before the DB instance is deleted.
variable "skip_final_snapshot" {
  type    = string
  default = "true" ## Please update this field based on your requirement
}

variable "snapshot_identifier" {
  type    = string
  default = "" ## Please update this field based on your requirement
}

variable "db_family" {
  description = "Database parameter group family"
  type        = string
  default     = "sqlserver-ex-15.0"
}

variable "rds_security_group_ids" {
  description = "Database security group"  
  type    = list
  default = [] ## Please update this field based on your requirement
}