# Basic Project Details

variable "environment" {
  description = "Specify the environment - dev/stg/test/prod"
}

variable "project_prefix" {
  type        = string
  description = "Specify the project name"
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

/* Deployment Stage

variable "ecs_cluster_name" {
  description = "ECS Cluster Name"
}



variable "ecs_service_name" {
  description = "Ecs Service Name"
}

variable "environment_bucket" {
  description = "environment bucket"
}

variable "repository_uri" {
  description = "repository uri"
}
variable "container_name" {
  description = "container name"
}*/
variable "service_name" {
  description = "Service Name"
}

variable "environment_bucket" {
  description = "environment bucket"
}

# Private CB
variable "cb_vpc_id" {
  description = "VPC for CB to run"
}

variable "cb_subnets" {
  description = "cb subnets"
  type        = list(string)
}

variable "cb_security_groups" {
  description = "cb security groups"
  type        = list(string)
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