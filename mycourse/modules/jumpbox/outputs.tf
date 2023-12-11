output "jumpbox-sg-id" {
  value = aws_security_group.jumpbox-sg.id
}

output "jumpbox-private-ip" {
  value = aws_instance.jumpbox.0.private_ip
}
