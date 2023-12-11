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
    values = ["services"]
  }
}

data "aws_subnet" "private_services" {
  count = length(data.aws_subnet_ids.private_services.ids)
  id    = element(tolist(data.aws_subnet_ids.private_services.ids), count.index)
}

resource "aws_instance" "ec2-server-linux" {
  count                       = var.linux_count
  ami                         = var.ec2_ami_id_linux
  associate_public_ip_address = false
  instance_type               = var.instance_type_linux
  vpc_security_group_ids      = [aws_security_group.ec2-server-sg.id]
  subnet_id                   = data.aws_subnet.private_services[count.index].id
  key_name                    = var.ec2_key_pair
  ebs_optimized               = var.ebs_optimized_linux
  iam_instance_profile        = var.create_iam_role ? aws_iam_instance_profile.ec2-server-profile[0].name : ""
  volume_tags                 = merge(var.common_tags, { Name = "${var.primary_name}-${var.environment}-${var.server_name}-linux" })
  tags = {
    Name          = "${var.primary_name}-${var.environment}-${var.server_name}-linux"
    "Environment" = var.environment
  }
}

resource "aws_instance" "ec2-server-windows" {
  count                       = 1
  ami                         = var.ec2_ami_id_windows
  associate_public_ip_address = false
  instance_type               = var.instance_type_windows
  vpc_security_group_ids      = [aws_security_group.ec2-server-sg.id]
  subnet_id                   = data.aws_subnet.private_services[count.index].id
  key_name                    = var.ec2_key_pair
  ebs_optimized               = var.ebs_optimized_windows
  iam_instance_profile        = var.create_iam_role ? aws_iam_instance_profile.ec2-server-profile[0].name : ""
  volume_tags                 = merge(var.common_tags, { Name = "${var.primary_name}-${var.environment}-${var.server_name}-windows" })
  tags = {
    Name          = "${var.primary_name}-${var.environment}-${var.server_name}-windows"
    "Environment" = var.environment
  }
}

resource "aws_security_group" "ec2-server-sg" {
  description = "Security Group for Ec2 server in ${var.environment} env"
  name        = "${var.primary_name}-${var.environment}-${var.server_name}"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name"        = "${var.primary_name}-${var.environment}-${var.server_name}"
    "Environment" = var.environment
  }
}

resource "aws_security_group_rule" "ec2-server-ssh-cidr" {
  security_group_id = aws_security_group.ec2-server-sg.id

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = var.sg_for_ssh
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
  count = var.create_iam_role ? 1 : 0
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

resource "aws_iam_instance_profile" "ec2-server-profile" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.primary_name}-${var.environment}-${var.server_name}-profile"
  role  = aws_iam_role.ec2-server[count.index].name
}

resource "aws_s3_bucket" "s3-bucket" {
  count  = length(var.s3_bucket_names)
  bucket = "${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}"
  acl    = "private"
  lifecycle_rule {
      abort_incomplete_multipart_upload_days = 0
      enabled            = true
      id                 = "life cycle rule for ${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}"
      expiration {
        days = 7
      }   
  }
  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    "Name"        = "${var.primary_name}-${var.environment}-${var.s3_bucket_names[count.index]}",
    "Environment" = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "block-s3-public-access" {
  count                   = length(var.s3_bucket_names)
  bucket                  = aws_s3_bucket.s3-bucket[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

data "aws_iam_policy_document" "eks-s3-policy-document" {
  # Used by Content and PDF Generation api
  dynamic "statement" {
    for_each = range(length(var.s3_bucket_names))
    content {
      sid     = "EKSS3Policy${statement.value}"
      actions = ["s3:*"]
      effect  = "Allow"
      resources = [
        "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[statement.value]}/*",
        "arn:aws:s3:::${var.primary_name}-${var.environment}-${var.s3_bucket_names[statement.value]}"
      ]
    }
  }
}

resource "aws_iam_role_policy" "eFront-role-S3-Policy" {
  count      = var.create_iam_role ? 1 : 0
  name       = "eFront-role-S3-Policy"
  role       = aws_iam_role.ec2-server[count.index].name
  policy     = data.aws_iam_policy_document.eks-s3-policy-document.json
  depends_on = [aws_iam_role.ec2-server]
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore-efront" {
  count      = var.create_iam_role ? 1 : 0
  role       = aws_iam_role.ec2-server[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
