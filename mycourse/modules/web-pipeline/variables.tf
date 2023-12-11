# Basic Project Details

variable "environment" {
  description = "Specify the environment - dev/stg/prod"
}

variable "web_app_env" {
  description = "Specify the web app environment development/staging/production"
}

variable "project_prefix" {
  description = "Specify the project name prefix"
}

#Github Repo Details

variable "repo_name" {
  description = "Repo Name"
}

variable "repo_url" {
  description = "Repo Url"
}

variable "branch_name" {
  description = "Branch Name"
}

#S3 Details

variable "artifact_bucket" {
  description = "Artifact Bucket Name"
}

variable "build_timeout" {
  description = "CodeBuild Build timeout"
}

variable "environment_bucket" {
  description = "environment bucket"
}

variable "deployment_bucket" {
  description = "deployment bucket"
}
variable "service_name" {
  description = "service name"
}
variable "invalidate_lambda_id" {
  description = "invalidate lambda id"
}
variable "invalidate_lambda_arn" {
  description = "invalidate lambda arn"
}
variable "distribution_id" {
  description = "CDN distribution id"
}
## Notifications
variable "notify_sns_arn" {
  description = "sns topic for build alerts"
}

variable "approve_sns_arn" {
  description = "sns topic for production deployment approval"
}

variable "production_approval" {
  type        = bool
  description = "Manual Approval for Prod Pipelines"
}