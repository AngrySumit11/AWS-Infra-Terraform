data "aws_iam_user" "doppler" {
  user_name = "course1_non_prod_doppler"
}
resource "aws_iam_user_policy" "iam_user_policy" {
  name = "${var.primary_name}-doppler-policy"
  user = data.aws_iam_user.doppler.user_name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSSMAccess",
            "Effect": "Allow",
            "Action": [
                "ssm:PutParameter",
                "ssm:LabelParameterVersion",
                "ssm:DeleteParameter",
                "ssm:RemoveTagsFromResource",
                "ssm:GetParameterHistory",
                "ssm:AddTagsToResource",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssm:DeleteParameters"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
