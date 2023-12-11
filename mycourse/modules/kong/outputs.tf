output "rds_endpoint" {
  value       = coalesce(aws_rds_cluster.course1.*.endpoint)
  description = "The endpoint for the course1 database"
}

output "rds_password" {
  sensitive   = true
  value       = random_string.db_password.result
  description = "The database password for course1"
}

output "master_password" {
  sensitive   = true
  value       = random_string.master_password.result
  description = "The master password for course1"
}

output "admin_token" {
  sensitive   = true
  value       = random_string.admin_token.result
  description = "The admin token for course1"
}

output "lb_endpoint_external" {
  value       = coalesce(aws_lb.external.*.dns_name)
  description = "The external load balancer endpoint"
}

output "lb_endpoint_internal" {
  value       = coalesce(aws_lb.internal.*.dns_name)
  description = "The internal load balancer endpoint"
}

output "course1_sns_arns" {
  value       = aws_sns_topic.course1-sns-topic.*.arn
  description = "List of ARNs for SNS"
}

output "course1_sqs_arns" {
  value       = aws_sqs_queue.course1-sqs-queues.*.arn
  description = "List of ARNs for SQS"
}

output "vpc_cidr" {
  value       = data.aws_vpc.vpc.cidr_block
  description = "VPC Cidr block"
}

output "vpc_id" {
  value       = data.aws_vpc.vpc.id
  description = "VPC Id"
}

output "postgresql-security-group" {
  value       = aws_security_group.postgresql.id
  description = "postgresql-security-group"
}

output "redis-security-group" {
  value       = aws_security_group.redis.id
  description = "redis-security-group"
}

output "course1-security-group" {
  value       = aws_security_group.course1.id
  description = "course1-security-group"
}

output "course1-security-group-external" {
  value       = aws_security_group.external-lb.id
  description = "course1-security-group-external"
}

output "course1-external-lb-dns" {
  value       = aws_lb.external.*.dns_name
  description = "course1 external lb dns"
}

output "course1-internal-lb-dns" {
  value       = aws_lb.internal.*.dns_name
  description = "course1 internal lb dns"
}

output "course1-external-lb-arn" {
  value       = aws_lb.external.*.arn
  description = "course1 external lb dns"
}

output "course1-internal-lb-arn" {
  value       = aws_lb.internal.*.arn
  description = "course1 internal lb dns"
}

output "kms_key_arn" {
  value       = aws_kms_alias.course1.target_key_arn
  description = "KMS key arn"
}
