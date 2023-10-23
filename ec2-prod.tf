#Variable to define most recent Ubuntu ami image
data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
resource "aws_key_pair" "nextcloud-keypair" {
  key_name   = "nextcloud-keypair"
  public_key = file(var.public_key_location) # Replace with the path to your local public key
}

# Define an AWS EC2 instance resource
resource "aws_instance" "web-server" {
  depends_on                  = [aws_db_instance.webapp_rds, aws_efs_file_system.nextcloud_efs]
  count                       = var.number_of_instances
  ami                         = data.aws_ami.ubuntu_ami.id # Replace with your desired Amazon Machine Image (AMI) ID
  instance_type               = var.instance_type          # Replace with your desired instance type
  key_name                    = aws_key_pair.nextcloud-keypair.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id] # Associate the instance with the bastion_security_group  
  subnet_id                   = aws_subnet.public_subnets[count.index % length(aws_subnet.public_subnets)].id
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"                       # Replace with your SSH username
    private_key = file(var.private_key_location) # Replace with your private key path
    host        = self.public_ip                 # Access the instance's public IP
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nfs-common unzip apache2 libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip -y",
      "wget -O /tmp/latest.zip https://download.nextcloud.com/server/releases/latest.zip",
      "sudo unzip /tmp/latest.zip -d /var/www/html",
      "sudo mkdir -p /var/www/html/nextcloud/data",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport '${aws_efs_file_system.nextcloud_efs.dns_name}':/ /var/www/html/nextcloud/data",
    ]
  }
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/update_inventory.sh '${self.public_ip}'"
  }
  provisioner "local-exec" {
    command = "bash -c 'while ! nc -z -w5 ${self.public_ip} 22; do echo \"Waiting for SSH to become available on ${self.public_ip}...\"; sleep 10; done; ansible-playbook -i inventory.ini --ssh-common-args \"-o StrictHostKeyChecking=no -o ConnectTimeout=30 -o ServerAliveInterval=60\" copy_files.yml -vv'"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chown -R www-data:www-data /var/www/html/nextcloud",
      "sudo a2dissite 000-default.conf",
      "sudo a2enmod rewrite",
      "sudo a2enmod headers",
      "sudo a2enmod env",
      "sudo a2enmod dir",
      "sudo a2enmod mime",
      "sudo systemctl enable apache2",
      "sudo systemctl reload apache2",
    ]
  }
  tags = {
    Name = "nextcloud-${count.index + 1}"
  }
}


