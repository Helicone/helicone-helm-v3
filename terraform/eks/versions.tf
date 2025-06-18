terraform {
  required_version = ">= 1.3.0"

  cloud { 
    # TODO Move to the helicone-eks organization
    organization = "helicone" 

    workspaces { 
      name = "helicone" 
    } 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    # cloudflare = {
    #   source  = "cloudflare/cloudflare"
    #   version = "~> 4.0"
    # }
  }
} 