resource "aws_efs_file_system" "nextcloud_efs" {
  creation_token   = "nextcloud-efs"
  performance_mode = "generalPurpose" # You can choose "maxIO" if needed
  throughput_mode  = "bursting"
  encrypted        = false # Set to true if you want the EFS to be encrypted

  tags = {
    Name = "nextcloud-efs"
  }
}

resource "aws_efs_mount_target" "efs_mount_targets" {
  count           = length(var.azs)
  file_system_id  = aws_efs_file_system.nextcloud_efs.id
  subnet_id       = aws_subnet.private_subnets[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}


resource "aws_efs_access_point" "efs_ap" {
  file_system_id = aws_efs_file_system.nextcloud_efs.id
}
