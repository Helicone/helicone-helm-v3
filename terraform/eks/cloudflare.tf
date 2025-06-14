# Cloudflare Provider Configuration
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Data source for the Cloudflare zone
data "cloudflare_zone" "helicone_test" {
  count = var.enable_helicone_test_domain ? 1 : 0
  name  = var.cloudflare_zone_name
}

# Data source for the helicone.ai Cloudflare zone
data "cloudflare_zone" "helicone_ai" {
  name = var.cloudflare_helicone_ai_zone_name
}

# CNAME record for the application subdomain pointing to AWS load balancer
resource "cloudflare_record" "helicone_app" {
  count   = var.enable_helicone_test_domain ? 1 : 0
  zone_id = data.cloudflare_zone.helicone_test[0].id
  name    = var.cloudflare_subdomain
  content = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
  type    = "CNAME"
  ttl     = 1  # TTL=1 when proxied
  proxied = true  # Enable Cloudflare proxy for HTTPS termination

  comment = "Managed by Terraform - Points to AWS EKS load balancer with Cloudflare proxy"

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodes,
    data.kubernetes_service.ingress_nginx
  ]
}

# Certificate validation records for ACM certificate
resource "cloudflare_record" "cert_validation" {
  count = var.enable_helicone_test_domain ? length(aws_acm_certificate.helicone_test_cert[0].domain_validation_options) : 0

  zone_id = data.cloudflare_zone.helicone_test[0].id
  name    = tolist(aws_acm_certificate.helicone_test_cert[0].domain_validation_options)[count.index].resource_record_name
  content = tolist(aws_acm_certificate.helicone_test_cert[0].domain_validation_options)[count.index].resource_record_value
  type    = tolist(aws_acm_certificate.helicone_test_cert[0].domain_validation_options)[count.index].resource_record_type
  ttl     = 60

  comment = "Managed by Terraform - ACM certificate validation"

  depends_on = [aws_acm_certificate.helicone_test_cert]
}

# Data source to resolve the load balancer hostname to IP addresses
data "dns_a_record_set" "ingress_lb" {
  host = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
}

# Root domain A records pointing to load balancer IPs
resource "cloudflare_record" "helicone_root" {
  count = var.enable_helicone_test_domain && var.create_root_domain_record ? length(data.dns_a_record_set.ingress_lb.addrs) : 0
  
  zone_id = data.cloudflare_zone.helicone_test[0].id
  name    = "@"  # Root domain
  content = data.dns_a_record_set.ingress_lb.addrs[count.index]
  type    = "A"
  ttl     = 300
  proxied = false

  comment = "Managed by Terraform - Root domain A record ${count.index + 1}"

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodes,
    data.kubernetes_service.ingress_nginx
  ]
}

# CNAME record for the helicone.ai application subdomain pointing to AWS load balancer
resource "cloudflare_record" "helicone_ai_app" {
  zone_id = data.cloudflare_zone.helicone_ai.id
  name    = var.cloudflare_helicone_ai_subdomain
  content = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
  type    = "CNAME"
  ttl     = 1  # TTL=1 when proxied
  proxied = true  # Enable Cloudflare proxy for HTTPS termination

  comment = "Managed by Terraform - Points to AWS EKS load balancer with Cloudflare proxy for helicone.ai"

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodes,
    data.kubernetes_service.ingress_nginx
  ]
}

# Certificate validation records for helicone.ai ACM certificate
resource "cloudflare_record" "helicone_ai_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.helicone_ai_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.cloudflare_zone.helicone_ai.id
  name    = each.value.name
  content = each.value.record
  type    = each.value.type
  ttl     = 60

  comment = "Managed by Terraform - ACM certificate validation for helicone.ai"

  depends_on = [aws_acm_certificate.helicone_ai_cert]
}

# Root domain A records for helicone.ai pointing to load balancer IPs
resource "cloudflare_record" "helicone_ai_root" {
  count = var.create_helicone_ai_root_domain_record ? length(data.dns_a_record_set.ingress_lb.addrs) : 0
  
  zone_id = data.cloudflare_zone.helicone_ai.id
  name    = "@"  # Root domain
  content = data.dns_a_record_set.ingress_lb.addrs[count.index]
  type    = "A"
  ttl     = 300
  proxied = false

  comment = "Managed by Terraform - Root domain A record ${count.index + 1} for helicone.ai"

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodes,
    data.kubernetes_service.ingress_nginx
  ]
}