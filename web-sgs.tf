variable "web_sg_ports" {
  type        = list(number)
  description = "List of ingress ports"
  default     = [22, 80, 443]
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow list for Web app"
  vpc_id      = aws_vpc.main.id



  dynamic "ingress" {
    for_each = var.web_sg_ports
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
    Name = "allow_webapp_sg"
  }

}