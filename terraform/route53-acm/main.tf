terraform {
  required_version = ">= 1.0"
  
  cloud { 
    organization = "helicone" 

    workspaces { 
      name = "helicone-route53-acm" 
    } 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.region
  
  default_tags {
    tags = var.tags
  }
}

# Data source to get EKS state outputs from Terraform Cloud
data "terraform_remote_state" "eks" {
  backend = "remote"
  
  config = {
    organization = "helicone"
    workspaces = {
      name = "helicone"  # This matches the EKS workspace name
    }
  }
}

# Route 53 configuration for heliconetest.com
# This assumes you have a hosted zone already created for heliconetest.com
data "aws_route53_zone" "helicone" {
  name         = "heliconetest.com"
  private_zone = false
}

# Local value for ELB zone ID (us-west-2) - Application Load Balancer
locals {
  elb_zone_id = "Z1H1FL5HABSF5"  # This is the canonical hosted zone ID for Application Load Balancers in us-west-2
  
  # Check if we have valid EKS outputs
  has_load_balancer = try(data.terraform_remote_state.eks.outputs.load_balancer_hostname, null) != null
}

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

# Create A record for heliconetest.com pointing to the load balancer
resource "aws_route53_record" "helicone_main" {
  count           = local.has_load_balancer ? 1 : 0
  zone_id         = data.aws_route53_zone.helicone.zone_id
  name            = "heliconetest.com"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.terraform_remote_state.eks.outputs.load_balancer_hostname
    zone_id                = local.elb_zone_id
    evaluate_target_health = true
  }
}

# Create A record for grafana.heliconetest.com pointing to the load balancer
resource "aws_route53_record" "helicone_grafana" {
  count           = local.has_load_balancer ? 1 : 0
  zone_id         = data.aws_route53_zone.helicone.zone_id
  name            = "grafana.heliconetest.com"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.terraform_remote_state.eks.outputs.load_balancer_hostname
    zone_id                = local.elb_zone_id
    evaluate_target_health = true
  }
}

# Create A record for argocd.heliconetest.com pointing to the load balancer
resource "aws_route53_record" "helicone_argocd" {
  count           = local.has_load_balancer ? 1 : 0
  zone_id         = data.aws_route53_zone.helicone.zone_id
  name            = "argocd.heliconetest.com"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.terraform_remote_state.eks.outputs.load_balancer_hostname
    zone_id                = local.elb_zone_id
    evaluate_target_health = true
  }
}

# Note: Certificate validation for helicone-test.com and helicone.ai 
# is handled by the Cloudflare module to avoid circular dependencies 