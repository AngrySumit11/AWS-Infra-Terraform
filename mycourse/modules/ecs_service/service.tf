locals {
  task_secrets = [
    for k, v in var.secrets : {
      name      = k
      valueFrom = v
    }
  ]

  task_environment = [
    for k, v in var.environment_vars : {
      name  = k
      value = v
    }
  ]
}

resource "aws_ecs_task_definition" "td" {
  family                   = "${var.name}-${var.environment}"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = [var.container_platform]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions = templatefile("${path.module}/service.json.tpl",
    {
      c_name            = var.container_name,
      c_port            = var.container_port,
      expose_ssh_port   = var.expose_ssh_port,
      log_group_name    = var.log_group_name,
      log_stream_prefix = var.name,
      repo_secret       = var.repo_secret,
      image             = var.image,
      secrets           = local.task_secrets,
      environment       = local.task_environment,
      entrypoint        = var.entrypoint,
      task_role_arn     = var.task_role_arn
      network_mode      = var.network_mode
    }
  )
  tags = {
    Name  = var.name
    Env   = var.environment
    Owner = var.owner
  }
}

data "aws_ecs_task_definition" "td" {
  task_definition = aws_ecs_task_definition.td.family
  depends_on = [
    aws_ecs_task_definition.td
  ]
}

resource "aws_service_discovery_service" "sds" {
  count = var.service_discovery_namespace_id == "" ? 0 : 1
  name  = var.name
  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  tags = {
    Name  = var.name
    Env   = var.environment
    Owner = var.owner
  }
}

resource "aws_ecs_service" "service" {
  name                               = var.name
  cluster                            = var.ecs_cluster
  task_definition                    = "${data.aws_ecs_task_definition.td.family}:${data.aws_ecs_task_definition.td.revision}"
  desired_count                      = var.desired_container_count
  launch_type                        = var.container_platform
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_percent
  health_check_grace_period_seconds  = length(var.target_group_arns) > 0 ? 10 : null
  platform_version                   = var.container_platform == "FARGATE" ? var.platform_version : null

  /*network_configuration {
    security_groups  = var.ecs_security_groups
    subnets          = var.ecs_subnets
    assign_public_ip = var.assign_public_ip
  }*/
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
  dynamic "load_balancer" {
    for_each = var.target_group_arns

    content {
      target_group_arn = load_balancer.value
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  dynamic "service_registries" {
    for_each = aws_service_discovery_service.sds
    content {
      registry_arn = service_registries.value.arn
    }
  }

  tags = {
    Name  = var.name
    Env   = var.environment
    Owner = var.owner
  }
}
