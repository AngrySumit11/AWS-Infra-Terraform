variable "name" {
  type        = string
  description = "Name of the ECS Service"
}

variable "image" {
  type        = string
  description = "ARN of the ECR image with tag"
}

variable "task_execution_role_arn" {
  type        = string
  description = "Task Execution Role ARN"
}

variable "task_role_arn" {
  type        = string
  default     = ""
  description = "Task Role ARN to be assumed by containers"
}

variable "platform_version" {
  type        = string
  default     = "LATEST"
  description = "Platform version for ECS"
}

variable "ecs_security_groups" {
  type        = list(string)
  description = "List of security groups for ECS"
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "List of ARNs of Target Groups"
}

variable "ecs_cluster" {
  type        = string
  description = "ECS Cluster Id"
}

variable "container_name" {
  type        = string
  description = "Name of the container"
}

variable "container_port" {
  type        = number
  default     = 0
  description = "Container port"
}

variable "expose_ssh_port" {
  type        = bool
  default     = false
  description = "Boolean to decide whether to expose ssh port for container or not"
}

variable "log_group_name" {
  type        = string
  description = "Name of the cloudwatch group name"
}

variable "cpu" {
  default     = 256
  description = "CPU limit to be assigned for container"
}

variable "memory" {
  default     = 512
  description = "Memory limit to be assigned for container"
}

variable "deployment_maximum_percent" {
  default     = 200
  description = "An upper limit on the number of tasks in a service that are allowed in the RUNNING or PENDING state during a deployment, as a percentage of the desired number of tasks"
}

variable "deployment_minimum_percent" {
  default     = 100
  description = "A lower limit on the number of tasks in a service that must remain in the RUNNING state during a deployment, as a percentage of the desired number of tasks"
}

variable "desired_container_count" {
  default     = 1
  description = "Desired container count"
}

variable "secrets" {
  default     = {}
  type        = map(string)
  description = "Key-Value pair of the secrets"
}

variable "environment_vars" {
  default     = {}
  type        = map(string)
  description = "Key-Value pair for environment variables in container"
}

variable "environment" {
  default     = "test"
  type        = string
  description = "Name of the environment e.g dev, test, prod"
}

variable "repo_secret" {
  type        = string
  default     = ""
  description = "Secret ARN for private repository"
}

variable "ecs_subnets" {
  type        = list(string)
  description = "List of subnets for ECS Service"
}

variable "service_discovery_namespace_id" {
  type        = string
  default     = ""
  description = "Namespace Id of the Service Discovery"
}

variable "entrypoint" {
  type        = list(string)
  default     = []
  description = "ENTRYPOINT for Dockerfile"
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign a public IP address to the ENI (Fargate launch type only)"
}

variable "container_platform" {
  type        = string
  default     = "EC2"
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE"
}

variable "owner" {
  type        = string
  default     = ""
  description = "Name or email id of the owner of the resource"
}

variable "network_mode" {
  type        = string
  default     = "bridge"
  description = "Network mode for ECS Service e.g awsvpc, bridge, host etc"
}
