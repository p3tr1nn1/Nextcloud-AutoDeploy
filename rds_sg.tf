variable "rds_sg_ports" {
  type        = list(number)
  description = "List of ingress ports"
  default     = [3306]
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow list for RDS instance"
  //vpc_id      = aws_vpc.my_vpc.id
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]

  dynamic "ingress" {
    for_each = var.rds_sg_ports
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
    Name = "allow_rds_sg"
  }

}

//test