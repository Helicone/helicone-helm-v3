# Helicone ACM Module

This Terraform module manages AWS Certificate Manager (ACM) certificates for Helicone domains.

## Overview

This module creates and manages SSL/TLS certificates for:

- `heliconetest.com` and `*.heliconetest.com`
- `helicone-test.com` and `*.helicone-test.com` (optional)
- `helicone.ai` and `*.helicone.ai`

## Usage

```hcl
module "acm" {
  source = "./terraform/acm"

  region = "us-west-2"

  enable_helicone_test_domain = true
  heliconetest_domain         = "heliconetest.com"
  helicone_test_domain        = "helicone-test.com"
  helicone_ai_domain          = "helicone.ai"

  tags = {
    Environment = "production"
    Project     = "helicone"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0

## Certificate Validation

The certificates are created with DNS validation method. The validation records need to be added to
the respective DNS providers:

- `heliconetest.com` - Validated via Route53 (see Route53 module)
- `helicone-test.com` - Validated via Cloudflare (see Cloudflare module)
- `helicone.ai` - Validated via Cloudflare (see Cloudflare module)

## Inputs

| Name                        | Description                                                    | Type          | Default               | Required |
| --------------------------- | -------------------------------------------------------------- | ------------- | --------------------- | :------: |
| region                      | AWS region for resources                                       | `string`      | `"us-west-2"`         |    no    |
| tags                        | Common tags to apply to all resources                          | `map(string)` | See variables.tf      |    no    |
| enable_helicone_test_domain | Whether to create ACM certificate for helicone-test.com domain | `bool`        | `false`               |    no    |
| heliconetest_domain         | The primary domain for ACM certificate                         | `string`      | `"heliconetest.com"`  |    no    |
| helicone_test_domain        | The helicone-test.com domain for ACM certificate               | `string`      | `"helicone-test.com"` |    no    |
| helicone_ai_domain          | The helicone.ai domain for ACM certificate                     | `string`      | `"helicone.ai"`       |    no    |

## Outputs

| Name                                         | Description                                              |
| -------------------------------------------- | -------------------------------------------------------- |
| certificate_arn                              | ARN of the ACM certificate for heliconetest.com          |
| certificate_domain_name                      | Domain name of the ACM certificate                       |
| certificate_validation_options               | Certificate validation options for heliconetest.com      |
| certificate_helicone_test_arn                | ARN of the ACM certificate for helicone-test.com         |
| certificate_helicone_test_domain_name        | Domain name of the ACM certificate for helicone-test.com |
| certificate_helicone_test_validation_options | Certificate validation options for helicone-test.com     |
| certificate_helicone_ai_arn                  | ARN of the ACM certificate for helicone.ai               |
| certificate_helicone_ai_domain_name          | Domain name of the ACM certificate for helicone.ai       |
| certificate_helicone_ai_validation_options   | Certificate validation options for helicone.ai           |

## Notes

- Certificates are created with `create_before_destroy` lifecycle rule to ensure zero downtime
  during updates
- All certificates include wildcard subdomains (e.g., \*.domain.com)
- Certificate validation must be completed within 72 hours of certificate creation
