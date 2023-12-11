variable "primary_name" {
  description = "Initials for any service"
  type        = string
}

variable "environment" {
  description = "Resource environment tag (i.e. dev, stage, prod)"
  type        = string
}

variable "server_name" {
  description = "Key identifier for server name"
  type        = string
}
