variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "white_list_ips" {
  type        = list(string)
  description = "List of IP's to allow traffic on the security group"
  default     = ["0.0.0.0/32"]

}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "number_of_instances" {
  type    = number
  default = 3

}

variable "autoconfigphp_location" {
  type    = string
  default = "autoconfig.php"
}

variable "rds_pass" {
  type    = string
  default = "fD2dfCCfw234"

}

variable "public_key_location" {
  type    = string
  default = "~/.ssh/id_rsa.pub"

}

variable "private_key_location" {
  type    = string
  default = "~/.ssh/id_rsa"

}