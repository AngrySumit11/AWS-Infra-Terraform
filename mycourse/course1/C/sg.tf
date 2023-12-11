resource "aws_security_group" "course1_non_prod_vpc_endpoint_sg" {
  name        = "${var.primary_name}-${var.environment}-vpc-endpoint_sg"
  deription = "SG for course1-non-prod vpc endpoint"
  vpc_id      = var.vpc_id

  ingress {
    deription = "cidr range for course1-non-prod vpc endpoint"  
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [""]
  }

  egress {
    deription = "cidr range for course1-non-prod vpc endpoint"  
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [""]
  }

  tags = {
    Name  = "${var.primary_name}-${var.environment}-vpc-endpoint_sg"
    Env   = var.environment
    Owner = var.owner
  }
}
