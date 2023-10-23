# Create a new load balancer
resource "aws_elb" "nextcloud-elb" {
  name    = "nextcloud-elb"
  subnets = [for subnet in aws_subnet.public_subnets : subnet.id]

  security_groups = [aws_security_group.web_sg.id]
  depends_on      = [tls_private_key.elb_key, aws_vpc.main]

  /*access_logs {
    bucket        = aws_vpc.main.id
    bucket_prefix = "bar"
    interval      = 60
  }*/

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate.cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  instances                   = [for instance in aws_instance.web-server : instance.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "nextcloud-elb"
  }
}

output "elb_access_point" {
  value = aws_elb.nextcloud-elb.dns_name
}