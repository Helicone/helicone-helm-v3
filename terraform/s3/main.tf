terraform {
    cloud { 
    
    organization = "helicone" 

    workspaces { 
      name = "helicone-s3" 
    } 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
}

resource "aws_s3_bucket" "helm_request_response_storage" {
  bucket = var.bucket_name

  tags = merge({
    Name        = "Helm Request Response Storage"
    Environment = var.environment
    Purpose     = "Request and response storage for Helm"
  }, var.tags)
}

resource "aws_s3_bucket_versioning" "helm_request_response_storage_versioning" {
  bucket = aws_s3_bucket.helm_request_response_storage.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "helm_request_response_storage_encryption" {
  bucket = aws_s3_bucket.helm_request_response_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "helm_request_response_storage_pab" {
  bucket = aws_s3_bucket.helm_request_response_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "helm_request_response_storage_cors" {
  bucket = aws_s3_bucket.helm_request_response_storage.id

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }
} 