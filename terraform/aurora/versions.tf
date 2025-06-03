terraform {
  required_version = ">= 1.3.0"

  cloud { 
    organization = "helicone" 

    workspaces { 
      name = "helicone-db" 
    } 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
} 