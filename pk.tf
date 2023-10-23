resource "tls_private_key" "elb_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "elb_cert" {
  private_key_pem = tls_private_key.elb_key.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.elb_key.private_key_pem
  certificate_body = tls_self_signed_cert.elb_cert.cert_pem
}
