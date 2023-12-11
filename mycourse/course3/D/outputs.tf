output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks.cluster_endpoint
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.eks.cluster_iam_role_arn
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = module.eks.worker_iam_role_arn
}

output "worker_iam_role_name" {
  description = "default IAM role ARN for EKS worker groups"
  value       = module.eks.worker_iam_role_name
}

output "cluster_security_group_id" {
  description = "cluster security group id"
  value       = module.eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "cluster primary security group id"
  value       = module.eks.cluster_primary_security_group_id
}

output "worker_security_group_id" {
  description = "worker security group id"
  value       = module.eks.worker_security_group_id
}
