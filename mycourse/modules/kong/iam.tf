data "aws_iam_policy_document" "course1-ssm" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }

  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/${var.service}/${var.environment}/*"]
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_alias.course1.target_key_arn]
  }
}

resource "aws_iam_role_policy" "course1-ssm" {
  count = var.create_course1_iam ? 1 : 0
  name  = format("%s-%s-ssm", var.service, var.environment)
  role  = aws_iam_role.course1[0].id

  policy = data.aws_iam_policy_document.course1-ssm.json
}

data "aws_iam_policy_document" "course1" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "course1" {
  count              = var.create_course1_iam ? 1 : 0
  name               = format("%s-%s", var.service, var.environment)
  assume_role_policy = data.aws_iam_policy_document.course1.json
  tags = {
    "Name" = format("%s-%s", var.service, var.environment)
  }
}

resource "aws_iam_instance_profile" "course1" {
  count = var.create_course1_iam ? 1 : 0
  name  = format("%s-%s", var.service, var.environment)
  role  = aws_iam_role.course1[0].id
}

# resource "aws_iam_role_policy_attachment" "course1-s3" {
#   count      = var.create_course1_iam ? 1 : 0
#   role       = aws_iam_role.course1[0].name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# }

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore-course1" {
  count      = var.create_course1_iam ? 1 : 0
  role       = aws_iam_role.course1[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
