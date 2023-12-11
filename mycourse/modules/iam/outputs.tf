output "iam_user_name" {
  value = aws_iam_user.iam_user.name
}

output "iam_access_key" {
  value = aws_iam_access_key.access_key.id
}
output "iam_secret" {
  value     = aws_iam_access_key.access_key.secret
  sensitive = true
}