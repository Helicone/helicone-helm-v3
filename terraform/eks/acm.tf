# ACM Certificate for heliconetest.com
resource "aws_acm_certificate" "helicone_cert" {
  domain_name               = "heliconetest.com"
  subject_alternative_names = ["*.heliconetest.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "heliconetest.com"
  })
}

# DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.helicone_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.helicone.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "helicone_cert" {
  certificate_arn         = aws_acm_certificate.helicone_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
} 