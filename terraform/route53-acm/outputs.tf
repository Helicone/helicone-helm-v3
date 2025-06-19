# Route53 outputs
output "route53_zone_id" {
  description = "ID of the Route53 hosted zone for heliconetest.com"
  value       = data.aws_route53_zone.helicone.zone_id
}

output "route53_zone_name" {
  description = "Name of the Route53 hosted zone"
  value       = data.aws_route53_zone.helicone.name
}

# ACM Certificate outputs for heliconetest.com
output "certificate_arn" {
  description = "ARN of the ACM certificate for heliconetest.com"
  value       = aws_acm_certificate_validation.helicone_cert.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = aws_acm_certificate.helicone_cert.domain_name
}

# ACM Certificate outputs for helicone-test.com
output "certificate_helicone_test_arn" {
  description = "ARN of the ACM certificate for helicone-test.com"
  value       = var.enable_helicone_test_domain ? aws_acm_certificate.helicone_test_cert[0].arn : null
}

output "certificate_helicone_test_domain_name" {
  description = "Domain name of the ACM certificate for helicone-test.com"
  value       = var.enable_helicone_test_domain ? aws_acm_certificate.helicone_test_cert[0].domain_name : null
}

output "certificate_helicone_test_validation_options" {
  description = "Certificate validation options for helicone-test.com (to be added to Cloudflare)"
  value       = var.enable_helicone_test_domain ? aws_acm_certificate.helicone_test_cert[0].domain_validation_options : null
  sensitive   = false
}

# ACM Certificate outputs for helicone.ai
output "certificate_helicone_ai_arn" {
  description = "ARN of the ACM certificate for helicone.ai"
  value       = aws_acm_certificate.helicone_ai_cert.arn
}

output "certificate_helicone_ai_domain_name" {
  description = "Domain name of the ACM certificate for helicone.ai"
  value       = aws_acm_certificate.helicone_ai_cert.domain_name
}

output "certificate_helicone_ai_validation_options" {
  description = "Certificate validation options for helicone.ai (to be added to Cloudflare)"
  value       = aws_acm_certificate.helicone_ai_cert.domain_validation_options
  sensitive   = false
}

# DNS records info
output "dns_records_created" {
  description = "Information about created DNS records"
  value = {
    main_domain    = local.has_load_balancer ? aws_route53_record.helicone_main[0].name : "Not created - load balancer not available"
    grafana_domain = local.has_load_balancer ? aws_route53_record.helicone_grafana[0].name : "Not created - load balancer not available"  
    argocd_domain  = local.has_load_balancer ? aws_route53_record.helicone_argocd[0].name : "Not created - load balancer not available"
  }
} 