resource "aws_security_group" "ecs_tasks" {
  count       = length(var.list_of_services)
  name        = "${var.list_of_services[count.index]}-${var.environment}-task-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.list_of_services[count.index]}-${var.environment}-task-sg"
    Env   = var.environment
    Owner = var.owner
  }
}

resource "aws_security_group_rule" "task_sg_rule" {
  count                    = length(var.list_of_services)
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ecs_tasks[count.index].id
  depends_on               = [aws_security_group.ecs_tasks]
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-${var.environment}-lb-sg"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.app_name}-${var.environment}-lb-sg"
    Env   = var.environment
    Owner = var.owner
  }
}

resource "aws_security_group_rule" "cloudflare_sg_http" {
  type              = "ingress"
  to_port           = 80
  from_port         = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "cloudflare_sg_https" {
  type              = "ingress"
  to_port           = 443
  from_port         = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}


resource "aws_security_group" "noingress" {
  name        = "${var.app_name}-${var.environment}-noingress-sg"
  description = "SG for Lambda Functions"
  vpc_id      = var.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.app_name}-${var.environment}-noingress-sg"
    Env   = var.environment
    Owner = var.owner
  }
}


