output "jumpbox-sg-id" {
  value = aws_security_group.ec2-server-sg.id
}

output "ec2-instance-id" {
  value = aws_instance.ec2-server[0].id
}
