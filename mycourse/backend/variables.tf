variable "aws_profile" {
  type        = string
  default     = "usa-prod"
  description = "Region id for S3 Bucket to be used as backend"
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "Region id for S3 Bucket to be used as backend"
}

variable "common_tags" {
  type = map(string)
  default = {
    "terraform" = "true"
  }
}

variable "tf_backend_bucket_name" {
  type        = string
  default     = "usa-terraform-backend"
  description = "S3 Bucket name to be used as backend"
}

variable "dynamodb_table_name" {
  type        = string
  default     = "terraform-lock"
  description = "DynamoDB Table name to be used as backend"
}

variable "tf_logging_bucket" {
  type        = string
  default     = "seq-logs-elb-us-west-2"
  description = "S3 bucket for logging"
}

variable "tf_logging_bucket_prefix" {
  type        = string
  default     = "/"
  description = "Prefix of S3 bucket for logging"
}
