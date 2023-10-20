#Variable to define most recent Ubuntu ami image
data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["amazon"]


  filter {
    name = "name"
    //values = ["amzn2-ami-hvm*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "nextcloud-keypair" {
  key_name   = "nextcloud-keypair"
  public_key = file(var.public_key_location) # Replace with the path to your local public key
}


# Define an AWS EC2 instance resource
resource "aws_instance" "web-server" {
  ami                         = data.aws_ami.ubuntu_ami.id # Replace with your desired Amazon Machine Image (AMI) ID
  instance_type               = var.instance_type          # Replace with your desired instance type
  key_name                    = aws_key_pair.nextcloud-keypair.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id] # Associate the instance with the bastion_security_group
  subnet_id                   = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true



  tags = {
    Name = "web-server"
  }
  depends_on = [ aws_db_instance.webapp_rds ]


}

resource "aws_eip" "webserver_ip" {
  instance   = aws_instance.web-server.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]

  # Run a Bash script with the public IP as an argument to update the Ansible inventory.ini file.
  provisioner "local-exec" {
    //command = "bash ${path.module}/update_inventory.sh '${aws_eip.webserver_ip.public_ip}'"
    //command = "bash ${path.module}/update_inventory.sh '${self.public_ip}'"
    command = "bash ${path.module}/scripts/update_inventory.sh '${self.public_ip}'"

  }
  provisioner "local-exec" {
    command = "sleep 5 && ansible-playbook -i inventory.ini -e 'instance_ip=${self.public_ip}' --ssh-common-args '-o StrictHostKeyChecking=no -o ConnectTimeout=30 -o ServerAliveInterval=60' run_script.yml"

  }
}

output "website_public_ip" {
  value = "Website is runing https://${aws_eip.webserver_ip.public_ip}"

}


