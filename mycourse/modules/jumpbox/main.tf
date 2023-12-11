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
  count = length(data.aws_subnet_ids.private_services.ids)
  id    = element(tolist(data.aws_subnet_ids.private_services.ids), count.index)
}

resource "aws_key_pair" "jumpbox-keypair" {
  key_name   = "${var.key_pair_prefix}-${var.environment}"
  public_key = var.ssh_public_key
  tags = {
    "Name" = "${var.key_pair_prefix}-${var.environment}"
  }
}

resource "aws_instance" "jumpbox" {
  count                       = 1
  ami                         = var.ami_id
  associate_public_ip_address = false
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.jumpbox-sg.id]
  subnet_id                   = data.aws_subnet.private_services[count.index].id
  key_name                    = aws_key_pair.jumpbox-keypair.key_name
  iam_instance_profile        = var.create_iam_role ? aws_iam_instance_profile.jumpbox-profile[0].name : "${var.primary_name}-${var.app_name}-${var.environment}-profile"
  volume_tags                 = merge(var.tags, { Name = "${var.primary_name}-${var.app_name}-${var.environment}" })
  disable_api_termination     = false
  ebs_optimized               = true
  hibernation                 = false
  monitoring                  = false
  user_data                   = data.template_cloudinit_config.cloud-init.rendered
  root_block_device {
      delete_on_termination = true
      volume_size           = var.volume_size
  }
  tags = {
    Name = "${var.primary_name}-${var.app_name}-${var.environment}"
  }
}

resource "aws_security_group" "jumpbox-sg" {
  description = "Jumpbox Security Group for ${var.environment} env"
  name        = "${var.primary_name}-${var.app_name}-${var.environment}"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "${var.primary_name}-${var.app_name}-${var.environment}"
  }
}

resource "aws_security_group_rule" "jumpbox-sg-ssh" {
  security_group_id = aws_security_group.jumpbox-sg.id

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = [data.aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "jumpbox-sg-egress" {
  security_group_id = aws_security_group.jumpbox-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_iam_role" "jumpbox-role" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.primary_name}-${var.app_name}-${var.environment}-role"
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

resource "aws_iam_role_policy_attachment" "jumpbox-policy-attachment" {
  count      = var.create_iam_role ? length(var.list_of_iam_policy_arn) : 0
  role       = aws_iam_role.jumpbox-role[0].name
  policy_arn = var.list_of_iam_policy_arn[count.index]
}

resource "aws_iam_instance_profile" "jumpbox-profile" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.primary_name}-${var.app_name}-${var.environment}-profile"
  role  = aws_iam_role.jumpbox-role[count.index].name
}
