variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "helicone"
    ManagedBy   = "terraform"
  }
}

# Domain Configuration
variable "enable_helicone_test_domain" {
  description = "Whether to create ACM certificate for helicone-test.com domain"
  type        = bool
  default     = false
}

variable "heliconetest_domain" {
  description = "The primary domain for Route53 hosted zone and ACM certificate"
  type        = string
  default     = "heliconetest.com"
}

variable "helicone_test_domain" {
  description = "The helicone-test.com domain for ACM certificate"
  type        = string
  default     = "helicone-test.com"
}

variable "helicone_ai_domain" {
  description = "The helicone.ai domain for ACM certificate"
  type        = string
  default     = "helicone.ai"
}

# EKS remote state configuration (for flexibility)
variable "eks_terraform_workspace" {
  description = "Name of the EKS Terraform workspace"
  type        = string
  default     = "helicone"
}

variable "terraform_organization" {
  description = "Terraform Cloud organization name"
  type        = string
  default     = "helicone"
} 