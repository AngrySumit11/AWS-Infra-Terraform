variable "environment" {
  description = "Env name"
  type        = string
  default     = "dev"
}

variable "web_app_env" {
  description = "Web App Env name"
  type        = string
  default     = "development"
}

variable "vpc" {
  description = "VPC Name for the AWS account and region specified"
  type        = string
  default     = "course1-non-prod"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "subnet_tag" {
  description = "Tag used on subnets to define Tier"
  type        = string
  default     = "Tier"
}

variable "private_subnets" {
  description = "Subnet tag on private subnets"
  type        = string
  default     = "private"
}

variable "public_subnets" {
  description = "Subnet tag on public subnets for external load balancers"
  type        = string
  default     = "public"
}

variable "list_of_services" {
  type        = list(any)
  description = "List of prefix names of services to be provisioned"
}

variable "list_of_services_external" {
  type        = list(any)
  description = "List of prefix names of services to be provisioned - external"
}

/*variable "public_subnets" {
  type    = list(any)
  description = "List of public subnets"
}*/


variable "owner" {
  type        = string
  description = "Name or email id of the owner of the resource"
}

variable "health_check_path" {
  type        = list(any)
  description = "Health check path to be configured in Target Group for the application"
}

variable "common_tags" {
  type = map(any)
  default = {
  }
  description = "Key-Value pair of the common tags to be applied to all taggable resources"
}

variable "app_name" {
  type        = string
  description = "Name of the app which is built using multiple services"
}

/*variable "cloudflare_ips" {
  type = list(any)
  description = "List of IP addresses to be whitelisted from CloudFlare"
}*/


/*variable "alb_host_header" {
  type    = string
  description = "Host header endpoint to be configured in ALB Listener rules"
}*/

variable "certificate_arn" {
  type        = string
  description = "AWS certificate ARN to be added to Load Balancer"
}

variable "container_platform" {
  type        = string
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE"
}


variable "primary_name" {
  description = "Initials for any service"
  type        = string
  default     = "course1"
}

variable "environment_common" {
  type    = string
  default = "non-prod"
}


variable "db_instance_class" {
  default = "db.t3.medium"
}


variable "db_family" {
  default = "aurora-postgresql14"
}

variable "service" {
  type    = string
  default = "course1"

}

variable "description" {
  description = "Resource description tag"
  type        = string

}

variable "database_name" {
  description = "Database Name"
  type        = string
  default     = "course1_db"
}


variable "db_final_snapshot_identifier" {
  description = "The final snapshot name of the RDS instance when it gets destroyed"
  type        = string
  default     = ""
}


variable "s3_bucket_names" {
  type    = list(string)
  default = [""]
}

variable "account_id" {
  description = "AWS Account Id"
  type        = string
}


variable "create_sqs" {
  type    = bool
  default = false
}


variable "list_of_queue_names" {
  description = "List of SQS Queue names used for course1"
  type        = list(string)
  default     = [""]
}


variable "sqs_iam" {
  description = "Iam user name for SQS"
  type        = string
  default     = ""
}


variable "domain_name_global" {
  description = "Global Domain Name for ACM Certificate"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain Name for ACM Certificate"
  type        = string
  default     = ""
}

variable "assets_bucket" {
  description = "Bucket Name for Assets"
  type        = string
  default     = ""
}


variable "media_bucket" {
  description = "Bucket Name for Media Objects"
  type        = string
  default     = ""
}

variable "course1admin_bucket" {
  description = "Bucket Name for Admin Objects"
  type        = string
  default     = ""
}

variable "artifact_bucket" {
  description = "Bucket Name for CodeBuild Artifact"
  type        = string
  default     = ""
}

variable "associate_lb_to_wafv2" {
  type    = bool
  default = true
}

variable "snapshot_arns" {
  type    = list(any)
  default     = [""]
}

variable "jumpbox_cidr" {
  type    = string
  default = ""
}

variable "list_services_subnet_cidrs" {
  type    = list(any)
  default = [""]
}

variable "persistence_svc_repo_url" {
  description = "Persistence Service Repo URL"
}

variable "integration_svc_repo_url" {
  description = "Integration Service Repo URL"
}

variable "notification_svc_repo_url" {
  description = "Notification Service Repo URL"
}

variable "course1app_svc_repo_url" {
  description = "course1 App Service Repo URL"
}

variable "course1upload_svc_repo_url" {
  description = "course1 App Service Repo URL"
}

variable "admin_web_repo_url" {
  description = "Admin Web Repo URL"
}

variable "serverless_repo_url" {
  description = "Serverless Repo URL"
}

variable "admin_web_repo_name" {
}

variable "serverless_repo_name" {
}

variable "persistence_svc_branch_name" {
  description = "Persistence Service Branch Name"
}

variable "integration_svc_branch_name" {
  description = "Integration Service Branch Name"
}

variable "notification_svc_branch_name" {
  description = "Notification Service Branch Name"
}

variable "course1app_svc_branch_name" {
  description = "course1 App Service Branch Name"
}

variable "course1upload_svc_branch_name" {
  description = "course1 Upload Service Branch Name"
}

variable "admin_web_branch_name" {
  description = "Admin Web Branch Name"
}

variable "serverless_branch_name" {
  description = "Serverless Branch Name"
}

variable "build_timeout" {
  description = "Build TimeOut"
  type        = number
  default     = 15
}

variable "persistence_ecs_repository_uri" {
  description = "ECR Repo uri for Persistence Service"
}

variable "integration_ecs_repository_uri" {
  description = "ECR Repo uri for Integration Service"
}

variable "notification_ecs_repository_uri" {
  description = "ECR Repo uri for Notification Service"
}

variable "course1app_ecs_repository_uri" {
  description = "ECR Repo uri for course1 App Service"
}

variable "course1upload_ecs_repository_uri" {
  description = "ECR Repo uri for course1 Upload Service"
}

variable "persistence_svc_service_name" {
  description = "Name of Service"
}

variable "notification_svc_service_name" {
  description = "Name of Service"
}

variable "integration_svc_service_name" {
  description = "Name of Service"
}

variable "course1app_svc_service_name" {
  description = "Name of Service"
}

variable "course1upload_svc_service_name" {
  description = "Name of Service"
}

variable "admin_web_service_name" {
  description = "Name of Service"
}

variable "serverless_service_name" {
  description = "Name of Service"
}

variable "invalidate_lambda_id" {
  description = "Name of Lambda Function for Invalidation"
}

variable "invalidate_lambda_arn" {
  description = "Arn of Lambda Function for Invalidation"
}

variable "admin_web_deployment_bucket" {
  description = "Deployment Bucket of Admin Web"
}

variable "environment_bucket" {
  description = "Name of Bucket containing ENV files"
}

variable "ecs_cluster_name" {
  description = "Name of ECS Cluster"
}

variable "project_prefix" {
  description = "Specify the project name"
}

variable "production_approval" {
  type        = bool
  description = "Approval for deployment in Prod ENV"
}

variable "snapshot_identifier" {
  type    = string
  default = "course1-dev-upgrade-encryption-cluster-v14-08-19-2022"
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "storage_encrypted" {
  type    = bool
  default = true
}

