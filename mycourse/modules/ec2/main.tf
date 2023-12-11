data "aws_vpc" "vpc" {
  state = "available"

  tags = {
    "Name" = var.vpc
  }
}

data "aws_subnet_ids" "private_services" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.private_subnets]
  }
  filter {
    name   = "tag:Env"
    values = [var.environment]
  }
  filter {
    name   = "tag:Category"
    values = [var.category]
  }
}

data "aws_subnet" "private_services" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = [var.name_tag]
  }
}

data "aws_region" "current" {}

resource "aws_instance" "ec2-server" {
  count                       = 1
  ami                         = var.ec2_ami_id
  associate_public_ip_address = false
  instance_type               = var.instance_type
  vpc_security_group_ids      = concat([aws_security_group.ec2-server-sg.id], var.vpc_security_group_ids)
  subnet_id                   = data.aws_subnet.private_services.id
  key_name                    = var.ec2_key_pair
  iam_instance_profile        = var.iam_instance_profile != "" ? var.iam_instance_profile : length(var.list_of_iam_policy_arn) > 0 ? aws_iam_instance_profile.ec2-server-profile[0].name : ""
  volume_tags                 = merge(var.tags, { Name = "${var.primary_name}-${var.environment}-${var.server_name}" })
  user_data                   = data.template_cloudinit_config.cloud-init.rendered
  root_block_device {
    volume_size = var.volume_size
  }
  tags = {
    Name = "${var.primary_name}-${var.environment}-${var.server_name}"
  }
}

resource "aws_ebs_volume" "extra_ebs" {
  count             = var.enable_extra_ebs ? 1 : 0
  availability_zone = data.aws_subnet.private_services.availability_zone_id
  size              = var.extra_ebs_size
}

resource "aws_volume_attachment" "extra_ebs_attachment" {
  count       = var.enable_extra_ebs ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.extra_ebs[count.index].id
  instance_id = aws_instance.ec2-server[count.index].id
}

resource "aws_security_group" "ec2-server-sg" {
  description = "Security Group for Ec2 server in ${var.environment} env"
  name        = "${var.primary_name}-${var.environment}-${var.server_name}"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "${var.primary_name}-${var.environment}-${var.server_name}"
  }
}

resource "aws_security_group_rule" "ec2-server-ssh-cidr" {
  count             = length(var.list_of_cidr_for_ssh)
  security_group_id = aws_security_group.ec2-server-sg.id

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = var.list_of_cidr_for_ssh
}

resource "aws_security_group_rule" "ec2-server-ssh-sg" {
  count             = var.source_sg_for_ssh != "" ? 1 : 0
  security_group_id = aws_security_group.ec2-server-sg.id

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = var.source_sg_for_ssh
}

resource "aws_security_group_rule" "ec2-server-rdp-cidr" {
  count             = length(var.list_of_cidr_for_rdp)
  security_group_id = aws_security_group.ec2-server-sg.id

  type      = "ingress"
  from_port = 3389
  to_port   = 3389
  protocol  = "tcp"

  cidr_blocks = var.list_of_cidr_for_rdp
}

resource "aws_security_group_rule" "ec2-server-rdp-sg" {
  count             = var.source_sg_for_rdp != "" ? 1 : 0
  security_group_id = aws_security_group.ec2-server-sg.id

  type      = "ingress"
  from_port = 3389
  to_port   = 3389
  protocol  = "tcp"

  source_security_group_id = var.source_sg_for_rdp
}

resource "aws_security_group_rule" "ec2-server-http-sg" {
  count             = var.source_sg_for_http != "" ? 1 : 0
  security_group_id = aws_security_group.ec2-server-sg.id

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  source_security_group_id = var.source_sg_for_http
}

resource "aws_security_group_rule" "ec2-server-sg-egress" {
  security_group_id = aws_security_group.ec2-server-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_iam_role" "ec2-server" {
  count = length(var.list_of_iam_policy_arn) > 0 ? 1 : 0
  name  = "${var.primary_name}-${var.environment}-${var.server_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "EC2AssumeROle"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2-server-policy-attachment" {
  count      = length(var.list_of_iam_policy_arn)
  role       = aws_iam_role.ec2-server[count.index].name
  policy_arn = var.list_of_iam_policy_arn[count.index]
}

resource "aws_iam_instance_profile" "ec2-server-profile" {
  count = length(var.list_of_iam_policy_arn) > 0 ? 1 : 0
  name  = "${var.primary_name}-${var.environment}-${var.server_name}-profile"
  role  = aws_iam_role.ec2-server[count.index].name
}
