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

# ACM Certificate for helicone-test.com (Cloudflare managed)
resource "aws_acm_certificate" "helicone_test_cert" {
  count                     = var.enable_helicone_test_domain ? 1 : 0
  domain_name               = "helicone-test.com"
  subject_alternative_names = ["*.helicone-test.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "helicone-test.com"
  })
}

# ACM Certificate for helicone.ai (Cloudflare managed)
resource "aws_acm_certificate" "helicone_ai_cert" {
  domain_name               = "helicone.ai"
  subject_alternative_names = ["*.helicone.ai"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "helicone.ai"
  })
}

# DNS validation records for heliconetest.com
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

# Certificate validation for heliconetest.com
resource "aws_acm_certificate_validation" "helicone_cert" {
  certificate_arn         = aws_acm_certificate.helicone_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}

# TODO Move these certs to the cloudflare module
# Certificate validation for helicone-test.com (automatic validation with Cloudflare)
# NOTE: Commented out to avoid circular dependency - validation handled by Cloudflare module
# resource "aws_acm_certificate_validation" "helicone_test_cert" {
#   count                   = var.enable_helicone_test_domain ? 1 : 0
#   certificate_arn         = aws_acm_certificate.helicone_test_cert[0].arn
#   validation_record_fqdns = var.enable_helicone_test_domain ? [for record in cloudflare_record.cert_validation : record.hostname] : []
  
#   timeouts {
#     create = "10m"
#   }
  
#   depends_on = [cloudflare_record.cert_validation]
# }

# Certificate validation for helicone.ai (automatic validation with Cloudflare)
# NOTE: Commented out to avoid circular dependency - validation handled by Cloudflare module
# resource "aws_acm_certificate_validation" "helicone_ai_cert" {
#   certificate_arn         = aws_acm_certificate.helicone_ai_cert.arn
#   validation_record_fqdns = [for record in cloudflare_record.helicone_ai_cert_validation : record.hostname]
  
#   timeouts {
#     create = "10m"
#   }
  
#   depends_on = [cloudflare_record.helicone_ai_cert_validation]
# } 