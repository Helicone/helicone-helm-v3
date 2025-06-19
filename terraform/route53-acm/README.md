# Route53/ACM Terraform Module

This module manages ACM SSL certificates and Route53 DNS records for the Helicone application. It's
designed to be used alongside the EKS module and optionally with the Cloudflare module.

## Purpose

This module handles:

- **ACM SSL Certificates**: Creates and manages SSL certificates for multiple domains
- **Route53 DNS Records**: Creates DNS records for the primary heliconetest.com domain
- **Certificate Validation**: Automatically validates certificates using DNS validation
- **Load Balancer Integration**: Creates DNS records pointing to the EKS load balancer

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│   EKS Module    │───▶│ Route53/ACM      │───▶│ Cloudflare      │
│                 │    │ Module           │    │ Module          │
│                 │    │                  │    │ (Optional)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │                        │                        │
        │                        │                        │
        ▼                        ▼                        ▼
  Load Balancer           ACM Certificates         Cloudflare DNS
  Hostname               Route53 DNS Records       External DNS
```

## Features

### ACM Certificates Created

- **heliconetest.com** - Primary domain with Route53 validation
- **helicone-test.com** - Optional domain for Cloudflare validation
- **helicone.ai** - Production domain for Cloudflare validation

### Route53 DNS Records

- **heliconetest.com** - Main application domain
- **grafana.heliconetest.com** - Grafana monitoring interface
- **argocd.heliconetest.com** - ArgoCD deployment interface

### Integration Features

- Reads EKS load balancer hostname via Terraform remote state
- Provides certificate validation options for Cloudflare module
- Conditional resource creation based on EKS infrastructure availability

## Dependencies

This module depends on:

1. **EKS Module**: Must be deployed first to provide load balancer hostname
2. **Route53 Hosted Zone**: `heliconetest.com` hosted zone must exist
3. **Terraform Cloud**: Remote state sharing between workspaces

## Configuration

### Basic Configuration

```hcl
# Enable optional helicone-test.com certificate
enable_helicone_test_domain = false

# Domain configuration (usually defaults are fine)
heliconetest_domain = "heliconetest.com"
helicone_test_domain = "helicone-test.com"
helicone_ai_domain = "helicone.ai"

# AWS region
region = "us-west-2"

# Tags for all resources
tags = {
  Environment = "production"
  Project     = "helicone"
  ManagedBy   = "terraform"
}
```

### Remote State Configuration

This module automatically reads from the EKS workspace:

```hcl
eks_terraform_workspace = "helicone"
terraform_organization = "helicone"
```

## Deployment Order

1. **Deploy EKS Module** first

   ```bash
   cd ../eks
   terraform apply
   ```

2. **Deploy Route53/ACM Module**

   ```bash
   cd ../route53-acm
   terraform apply
   ```

3. **Deploy Cloudflare Module** (optional)
   ```bash
   cd ../cloudflare
   terraform apply
   ```

## Outputs

The module provides these outputs for use by other modules:

### Certificate Information

- `certificate_arn` - ARN of heliconetest.com certificate
- `certificate_helicone_test_arn` - ARN of helicone-test.com certificate
- `certificate_helicone_ai_arn` - ARN of helicone.ai certificate

### Validation Options

- `certificate_helicone_test_validation_options` - For Cloudflare DNS validation
- `certificate_helicone_ai_validation_options` - For Cloudflare DNS validation

### Route53 Information

- `route53_zone_id` - Hosted zone ID for heliconetest.com
- `dns_records_created` - Information about created DNS records

## Certificate Validation Strategy

- **heliconetest.com**: Validated automatically via Route53 DNS records
- **helicone-test.com**: Certificate created, validation handled by Cloudflare module
- **helicone.ai**: Certificate created, validation handled by Cloudflare module

This approach avoids circular dependencies between modules while ensuring all certificates are
properly validated.

## Troubleshooting

### Load Balancer Not Available

If DNS records aren't created, check that:

1. EKS module has been applied successfully
2. Load balancer hostname is available in EKS outputs
3. Remote state access is configured correctly

### Certificate Validation Issues

- **heliconetest.com**: Check Route53 hosted zone exists and is accessible
- **Other domains**: Validation is handled by Cloudflare module

### Remote State Access Issues

Ensure:

- Terraform Cloud workspaces exist
- Organization name is correct
- Workspace has proper permissions for remote state sharing

## Security Considerations

- ACM certificates are created with DNS validation only
- Route53 records use alias records for better performance
- All resources are tagged for proper governance
- Sensitive outputs are marked appropriately

## Cost Optimization

- ACM certificates are free when used with AWS services
- Route53 hosted zone has minimal monthly cost
- DNS queries are charged per million queries
- No additional costs for certificate validation records
