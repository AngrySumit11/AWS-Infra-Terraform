module "ecs_cluster" {
  source                        = "../../../../course1/modules/ecs_cluster"
  name                          = "${var.app_name}-${var.environment}"
  owner                         = var.owner
  environment                   = var.environment
  ecr_repos                     = aws_ecr_repository.ecr_repos.*.arn
  cloudwatch_log_retention_days = 30
  vpc_id                        = var.vpc_id
  depends_on                    = [aws_ecr_repository.ecr_repos]
  secrets = [
    "arn:aws:secretsmanager:ap-southeast-1:${var.account_id}:secret:course1-app-*"
  ]
}

resource "aws_ecr_repository" "ecr_repos" {
  count = length(var.list_of_services)
  name  = "${var.list_of_services[count.index]}-${var.environment}-repo"
  tags = {
    Name  = "${var.list_of_services[count.index]}-${var.environment}-repo"
    Env   = var.environment
    Owner = var.owner
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_repos_policy" {
  count      = length(var.list_of_services)
  repository = aws_ecr_repository.ecr_repos[count.index].name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only last latest 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

/*resource "aws_service_discovery_private_dns_namespace" "fargate" {
  name        = "fargate.apps"
  description = "fargate service discovery"
  vpc         = var.vpc_id
}*/

module "ecs_services" {
  source = "../../../../course1/modules/ecs_service"
  #count                   = length(var.list_of_services)
  name                    = var.list_of_services[0]
  environment             = var.environment
  container_name          = var.list_of_services[0]
  owner                   = var.owner
  container_port          = 3000
  image                   = "${aws_ecr_repository.ecr_repos[0].repository_url}:latest"
  task_execution_role_arn = module.ecs_cluster.task_execution_role_arn[0]
  log_group_name          = module.ecs_cluster.cloudwatch_log_group_name
  ecs_cluster             = module.ecs_cluster.cluster_id
  ecs_security_groups     = [aws_security_group.ecs_tasks[0].id]
  ecs_subnets             = data.aws_subnet_ids.private_services.ids
  target_group_arns = [
    aws_lb_target_group.service_tg[0].id
  ]
  assign_public_ip           = false
  deployment_maximum_percent = 200
  deployment_minimum_percent = 100
  desired_container_count    = 1

  cpu    = 512
  memory = 1024

  #service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.fargate.id
  secrets = {
    course1_TOKEN = "arn:aws:secretsmanager:ap-southeast-1:${var.account_id}:secret:course1-app-course1app-service-dev-course1-zvnniH"
  }

  depends_on = [
    module.ecs_cluster,
    aws_security_group.ecs_tasks,
    aws_lb_target_group.service_tg
  ]
}


module "ecs_services01" {
  source = "../../../../course1/modules/ecs_service"
  #count                   = length(var.list_of_services)
  name                    = var.list_of_services[1]
  environment             = var.environment
  container_name          = var.list_of_services[1]
  owner                   = var.owner
  container_port          = 3001
  image                   = "${aws_ecr_repository.ecr_repos[1].repository_url}:latest"
  task_execution_role_arn = module.ecs_cluster.task_execution_role_arn[0]
  log_group_name          = module.ecs_cluster.cloudwatch_log_group_name
  ecs_cluster             = module.ecs_cluster.cluster_id
  ecs_security_groups     = [aws_security_group.ecs_tasks[1].id]
  ecs_subnets             = data.aws_subnet_ids.private_services.ids
  target_group_arns = [
    aws_lb_target_group.service_tg[1].id
  ]
  assign_public_ip           = false
  deployment_maximum_percent = 200
  deployment_minimum_percent = 100
  desired_container_count    = 1

  cpu    = 256
  memory = 512

  #service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.fargate.id
  secrets = {
    course1_TOKEN = "arn:aws:secretsmanager:ap-southeast-1:${var.account_id}:secret:course1-app-integration-service-dev-course1-Y1vHqa"
  }

  depends_on = [
    module.ecs_cluster,
    aws_security_group.ecs_tasks,
    aws_lb_target_group.service_tg
  ]
}


module "ecs_services02" {
  source = "../../../../course1/modules/ecs_service"
  #count                   = length(var.list_of_services)
  name           = var.list_of_services[2]
  environment    = var.environment
  container_name = var.list_of_services[2]
  owner          = var.owner
  #container_port          = 3001
  image                   = "${aws_ecr_repository.ecr_repos[2].repository_url}:latest"
  task_execution_role_arn = module.ecs_cluster.task_execution_role_arn[0]
  log_group_name          = module.ecs_cluster.cloudwatch_log_group_name
  ecs_cluster             = module.ecs_cluster.cluster_id
  ecs_security_groups     = [aws_security_group.ecs_tasks[2].id]
  ecs_subnets             = data.aws_subnet_ids.private_services.ids
  #target_group_arns = [
  # aws_lb_target_group.service_tg[1].id
  #]
  assign_public_ip           = false
  deployment_maximum_percent = 200
  deployment_minimum_percent = 100
  desired_container_count    = 1

  cpu    = 256
  memory = 512

  #service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.fargate.id

  depends_on = [
    module.ecs_cluster,
    aws_security_group.ecs_tasks,
    aws_lb_target_group.service_tg
  ]
}

module "ecs_services03" {
  source = "../../../../course1/modules/ecs_service"
  #count                   = length(var.list_of_services)
  name           = var.list_of_services[3]
  environment    = var.environment
  container_name = var.list_of_services[3]
  owner          = var.owner
  #container_port          = 3001
  image                   = "${aws_ecr_repository.ecr_repos[3].repository_url}:latest"
  task_execution_role_arn = module.ecs_cluster.task_execution_role_arn[0]
  log_group_name          = module.ecs_cluster.cloudwatch_log_group_name
  ecs_cluster             = module.ecs_cluster.cluster_id
  ecs_security_groups     = [aws_security_group.ecs_tasks[3].id]
  ecs_subnets             = data.aws_subnet_ids.private_services.ids
  #target_group_arns = [
  # aws_lb_target_group.service_tg[1].id
  #]
  assign_public_ip           = false
  deployment_maximum_percent = 200
  deployment_minimum_percent = 100
  desired_container_count    = 1

  cpu    = 256
  memory = 512

  #service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.fargate.id

  depends_on = [
    module.ecs_cluster,
    aws_security_group.ecs_tasks,
    aws_lb_target_group.service_tg
  ]
}

module "ecs_services04" {
  source = "../../../../course1/modules/ecs_service"
  #count                   = length(var.list_of_services)
  name                    = var.list_of_services[4]
  environment             = var.environment
  container_name          = var.list_of_services[4]
  owner                   = var.owner
  container_port          = 3002
  image                   = "${aws_ecr_repository.ecr_repos[4].repository_url}:latest"
  task_execution_role_arn = module.ecs_cluster.task_execution_role_arn[0]
  log_group_name          = module.ecs_cluster.cloudwatch_log_group_name
  ecs_cluster             = module.ecs_cluster.cluster_id
  ecs_security_groups     = [aws_security_group.ecs_tasks[4].id]
  ecs_subnets             = data.aws_subnet_ids.private_services.ids
  target_group_arns = [
    aws_lb_target_group.service_tg[2].id
  ]
  assign_public_ip           = false
  deployment_maximum_percent = 200
  deployment_minimum_percent = 100
  desired_container_count    = 1

  cpu    = 256
  memory = 512

  secrets = {
    course1_TOKEN = "arn:aws:secretsmanager:ap-southeast-1:${var.account_id}:secret:course1-app-upload-service-dev-course1-nfzikL"
  }
  #service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.fargate.id

  depends_on = [
    module.ecs_cluster,
    aws_security_group.ecs_tasks,
    aws_lb_target_group.service_tg
  ]
}

###################### IAM Roles for ECS#####################

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore-ECS" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent-${var.environment}"
  role = aws_iam_role.ecs_agent.name
}



################ ECS Autoscaling Group ############

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-${var.environment}-ecs-sg"
  description = "Security Group of EC2 in ECS ASG"
  vpc_id      = var.vpc_id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.221.10.202/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.221.0.0/16"]
    description = "vpc"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.app_name}-${var.environment}-ecs-sg"
  }
  
}

resource "aws_launch_configuration" "ecs_launch_config" {
  name                 = "${var.app_name}-${var.environment}-lc"
  image_id             = "ami-008f9288af809a5d6"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = data.template_cloudinit_config.cloud-init.rendered
  instance_type        = "c5.xlarge"
  key_name             = "course1-non-prod-keypair"
  lifecycle {
    ignore_changes = [name]
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "course1_app_ecs_asg" {
  name                      = "${var.app_name}-${var.environment}-ecs-asg"
  vpc_zone_identifier       = data.aws_subnet_ids.private_services.ids
  launch_configuration      = aws_launch_configuration.ecs_launch_config.name
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "EC2"
  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  tag {
    key                 = "Name"
    value               = "${var.app_name}-${var.environment}-ecs-asg"
    propagate_at_launch = true
  }
}

