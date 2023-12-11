resource "aws_iam_user" "iam_user" {
  name = "${var.primary_name}-${var.service_name}-user"
  path = "/"

  tags = {
    "Name" = "${var.primary_name}-${var.service_name}-user"
  }
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.iam_user.name
}
