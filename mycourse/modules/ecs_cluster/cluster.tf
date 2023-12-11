resource "aws_ecs_cluster" "cluster" {
  name = var.name

  tags = {
    Name  = var.name
    Env   = var.environment
    Owner = var.owner
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.environment}/${var.name}"
  retention_in_days = var.cloudwatch_log_retention_days
  tags = {
    Name  = var.name
    Env   = var.environment
    Owner = var.owner
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  count              = var.create_task_role ? 1 : 0
  name               = "${var.name}-${var.environment}-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name  = var.name
    Env   = var.environment
    Owner = var.owner
  }
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count  = var.create_task_role ? 1 : 0
  name   = "task-execution-role-cloudwatch-logs"
  role   = aws_iam_role.ecs_task_execution_role[count.index].name
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

data "aws_iam_policy_document" "secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = var.secrets
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_role_secrets" {
  count  = length(var.secrets) > 0 ? 1 : 0
  name   = "ecs-task-execution-role-secrets"
  role   = var.create_task_role ? aws_iam_role.ecs_task_execution_role[0].name : var.task_role_name
  policy = data.aws_iam_policy_document.secrets.json
}

data "aws_iam_policy_document" "ecr_repos" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = var.ecr_repos
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_role_pull_ecr_repos" {
  count  = length(var.ecr_repos) > 0 ? 1 : 0
  name   = "ecs-task-execution-role-pull-ecr-repos"
  role   = var.create_task_role ? aws_iam_role.ecs_task_execution_role[0].name : var.task_role_name
  policy = data.aws_iam_policy_document.ecr_repos.json
}
