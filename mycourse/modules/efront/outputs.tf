output "jumpbox-sg-id" {
  value = aws_security_group.ec2-server-sg.id
}

output "s3-bucket-ids" {
  value = aws_s3_bucket.s3-bucket.*.id
}

output "s3-bucket-arns" {
  value = aws_s3_bucket.s3-bucket.*.arn
}

output "efront-iam-role" {
  value = aws_iam_role.ec2-server.*.arn
}