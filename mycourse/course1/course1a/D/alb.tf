resource "aws_lb" "lb" {
  name               = "${var.app_name}-${var.environment}"
  subnets            = data.aws_subnet_ids.public.ids
  security_groups    = [aws_security_group.alb_sg.id]
  load_balancer_type = "application"
  idle_timeout       = 60

  access_logs {
    bucket  = "logs-elb-ap-southeast-1"
    enabled = true
  }

  tags = {
    Name  = "${var.app_name}-${var.environment}"
    Env   = var.environment
    Owner = var.owner
  }
}

resource "aws_lb_target_group" "service_tg" {
  count       = length(var.list_of_services_external)
  name        = "${var.list_of_services_external[count.index]}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  deregistration_delay = 120

  health_check {
    healthy_threshold   = "2"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "30"
    path                = var.health_check_path[count.index]
    unhealthy_threshold = "5"
  }
  tags = {
    Name  = "${var.list_of_services_external[count.index]}-${var.environment}-tg"
    Env   = var.environment
    Owner = var.owner
  }
  depends_on = [aws_lb.lb]
}

resource "aws_lb_listener" "service_tg_listener_http" {
  load_balancer_arn = aws_lb.lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [aws_lb.lb]
}

resource "aws_lb_listener" "service_tg_listener_https" {
  load_balancer_arn = aws_lb.lb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg[0].arn
  }
  depends_on = [aws_lb.lb]
}



resource "aws_lb_listener_rule" "static" {
  #count        = length(var.list_of_services_external)
  listener_arn = aws_lb_listener.service_tg_listener_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg[1].arn
  }

  condition {
    path_pattern {
      values = ["/course1-integration/*", "/course1-integration"]
    }
  }
  depends_on = [aws_lb_listener.service_tg_listener_https]
}

resource "aws_lb_listener_rule" "static1" {
  #count        = length(var.list_of_services_external)
  listener_arn = aws_lb_listener.service_tg_listener_https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg[2].arn
  }

  condition {
    path_pattern {
      values = ["/upload-service/*", "/upload-service"]
    }
  }
  depends_on = [aws_lb_listener.service_tg_listener_https]
}

resource "aws_lb_listener_certificate" "listener_certificate" {
  listener_arn    = aws_lb_listener.service_tg_listener_https.arn
  certificate_arn = var.certificate_arn
}
