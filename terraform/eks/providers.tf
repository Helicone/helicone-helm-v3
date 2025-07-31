# Default provider configuration
provider "aws" {
  region = var.region
}

# Since Terraform doesn't support dynamic provider configuration,
# we'll need to handle multi-region deployments differently.
# The module will use the default AWS provider and switch regions as needed.

# For Kubernetes and Helm providers, they will be configured 
# after the EKS clusters are created using data sources or outputs.