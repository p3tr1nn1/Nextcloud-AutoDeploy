resource "aws_db_subnet_group" "default" {
  name = "main_db"

  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  tags = {
    Name = "My DB subnet group"
  }

}

resource "aws_db_instance" "webapp_rds" {

  identifier            = "webapp-rds"
  instance_class        = "db.t3.micro"
  allocated_storage     = 5
  max_allocated_storage = 20
  engine                = "mariadb"
  engine_version        = "10.6.14"

  username = "dbuser"
  password = var.rds_pass

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  # Pass RDS variables to update the nextcloud autoconfig.php file.
  provisioner "local-exec" {
    //command = "bash ${path.module}/autoconfig-php.sh '${aws_db_instance.webapp_rds.password}' '${aws_db_instance.webapp_rds.address}'"
    command = "bash ${path.module}/scripts/autoconfig-php.sh '${var.rds_pass}' '${aws_db_instance.webapp_rds.address}'"



  }

}

/*output "rds_address" {
  value = aws_db_instance.webapp_rds.address
}

output "rds_arn" {
  value = aws_db_instance.webapp_rds.arn
}

output "rds_db_name" {
  value = aws_db_instance.webapp_rds.db_name
}

output "rds_port" {
  value = aws_db_instance.webapp_rds.port
}*/

