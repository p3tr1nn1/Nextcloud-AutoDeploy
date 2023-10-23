variable "efs_sg_ports" {
  type        = list(number)
  description = "List of ingress ports"
  default     = [2049]
}

resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "Allow list for EFS"
  vpc_id      = aws_vpc.main.id



  dynamic "ingress" {
    for_each = var.efs_sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_efs_sg"
  }

}