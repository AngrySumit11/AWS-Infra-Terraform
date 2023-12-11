//data "aws_subnet_ids" "public_egress" {
//  vpc_id = data.aws_vpc.vpc.id
//
//  filter {
//    name   = "tag:Tier"
//    values = ["public"]
//  }
//  filter {
//    name   = "tag:Env"
//    values = [var.environment]
//  }
//  filter {
//    name   = "tag:Category"
//    values = ["egress"]
//  }
//}
//
//data "aws_subnet" "public_egress" {
//  count = length(data.aws_subnet_ids.public_egress.ids)
//  id    = element(tolist(data.aws_subnet_ids.public_egress.ids), count.index)
//}
//
//module "netbox" {
//  source = "../../modules/ec2"
//  ec2_ami_id = "ami-0a2bb777a0f23598c"
//  environment = var.environment
//  primary_name = var.primary_name
//  server_name = "netbox"
//  vpc = var.vpc
//  ec2_key_pair = "default-keypair"
//  list_of_cidr_for_ssh = ["10.219.9.31/32"]
//  category = "local"
//  source_sg_for_http = "sg-002831c2ab822759d"
//}
//
//module "common-alb" {
//  source  = "terraform-aws-modules/alb/aws"
//  version = "~> v5.0"
//
//  name = "common-${var.environment}"
//
//  load_balancer_type = "application"
//
//  vpc_id             = data.aws_vpc.vpc.id
//  subnets            = data.aws_subnet.public_egress.*.id
//  security_groups    = ["sg-002831c2ab822759d"]
//
//  access_logs = {
//    bucket = "seq-logs-elb-us-west-2"
//  }
//
//  target_groups = [
//    {
//      name_prefix      = "common"
//      backend_protocol = "HTTP"
//      backend_port     = 80
//      target_type      = "instance"
//      targets = [
//        {
//          target_id = module.netbox.ec2-instance-id
//          port = 80
//        }
//      ]
//    }
//  ]
//
//  http_tcp_listeners = [
//    {
//      port        = 80
//      protocol    = "HTTP"
//      action_type = "redirect"
//      redirect = {
//        port        = "443"
//        protocol    = "HTTPS"
//        status_code = "HTTP_301"
//      }
//    }
//  ]
//
//  https_listeners = [
//    {
//      port                 = 443
//      certificate_arn      = "arn:aws:acm:us-west-2:accountid:certificate/bfe3f03c-0c33-4fc6-9f46-a03ecd5680dd"
//      action_type          = "fixed-response"
//      fixed_response  = {
//        content_type         = "text/html"
//        message_body         = "Invalid host"
//        status_code          = "503"
//      }
//
////      action_type = "redirect"
////      path        = "/"
////      host        = "netbox-non-prod.apps.course1-capital.net"
////      port        = "443"
////      query       = ""
////      protocol    = "HTTPS"
////      status_code = "HTTP_302"
//    }
//  ]
//
//  https_listener_rules = [
////    {
////      https_listener_index = 0
////      priority             = 5000
////
////      actions = [{
////        type        = "redirect"
////        status_code = "HTTP_302"
////        host        = "netbox-non-prod.apps.course1-capital.net"
////        path        = "/"
////        query       = ""
////        protocol    = "HTTPS"
////      }]
////      conditions = [{
////        path_patterns = ["/*"]
////      }]
////    },
//    {
//      https_listener_index = 0
//      priority             = 2
//
//      actions = [{
//        type        = "forward"
//        target_group_index = 0
//      }]
//
//      conditions = [{
//        host_headers = ["netbox-non-prod.apps.course1-capital.net"]
//        path_patterns = ["/*"]
//      }]
//    }
//  ]
//}
//
//resource "aws_route53_record" "netbox" {
//  zone_id = data.aws_route53_zone.zone[0].zone_id
//  name    = "netbox-non-prod.apps.course1-capital.net"
//  type    = "CNAME"
//  ttl     = "60"
//  records = [module.common-alb.this_lb_dns_name]
//}
