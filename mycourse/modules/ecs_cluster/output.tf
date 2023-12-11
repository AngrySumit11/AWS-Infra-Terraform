output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.*.arn
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}