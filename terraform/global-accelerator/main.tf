terraform {
  cloud { 
    organization = "helicone" 

    workspaces { 
      name = "helicone-global-accelerator" 
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
  # not used for anything actually so can be hard coded
  region = "us-east-1"
}

# Global Accelerator
resource "aws_globalaccelerator_accelerator" "helicone_global_accelerator" {
  name            = var.accelerator_name
  ip_address_type = var.ip_address_type
  enabled         = var.enabled

  attributes {
    flow_logs_enabled   = var.flow_logs_enabled
    flow_logs_s3_bucket = var.flow_logs_s3_bucket
    flow_logs_s3_prefix = var.flow_logs_s3_prefix
  }

  tags = merge({
    Name        = "Helicone Global Accelerator"
    Environment = var.environment
    Purpose     = "Load balancing across regions for EKS clusters"
  }, var.tags)
}

# TCP Listener on port 443
resource "aws_globalaccelerator_listener" "tcp_listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.helicone_global_accelerator.id
  client_affinity = var.client_affinity
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

# Additional listener for port 80 (HTTP)
resource "aws_globalaccelerator_listener" "tcp_listener_http" {
  accelerator_arn = aws_globalaccelerator_accelerator.helicone_global_accelerator.id
  client_affinity = var.client_affinity
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

# Endpoint Groups for each region (HTTPS)
resource "aws_globalaccelerator_endpoint_group" "endpoint_groups" {
  for_each = var.endpoint_regions

  listener_arn = aws_globalaccelerator_listener.tcp_listener.id

  endpoint_group_region         = each.key
  traffic_dial_percentage       = each.value.traffic_percentage
  health_check_interval_seconds = var.health_check_interval_seconds
  health_check_path             = var.health_check_path
  health_check_protocol         = var.health_check_protocol
  health_check_port             = var.health_check_port
  threshold_count               = var.threshold_count

  dynamic "endpoint_configuration" {
    for_each = each.value.alb_arns
    content {
      endpoint_id = endpoint_configuration.value
      weight      = var.endpoint_weight
      client_ip_preservation_enabled = true
    }
  }

  dynamic "port_override" {
    for_each = var.port_overrides
    content {
      listener_port = port_override.value.listener_port
      endpoint_port = port_override.value.endpoint_port
    }
  }
}

# Endpoint Groups for each region (HTTP)
resource "aws_globalaccelerator_endpoint_group" "endpoint_groups_http" {
  for_each = var.endpoint_regions

  listener_arn = aws_globalaccelerator_listener.tcp_listener_http.id

  endpoint_group_region         = each.key
  traffic_dial_percentage       = each.value.traffic_percentage
  health_check_interval_seconds = var.health_check_interval_seconds
  health_check_path             = var.health_check_path
  health_check_protocol         = "HTTP"
  health_check_port             = 80
  threshold_count               = var.threshold_count

  dynamic "endpoint_configuration" {
    for_each = each.value.alb_arns
    content {
      endpoint_id = endpoint_configuration.value
      weight      = var.endpoint_weight
      client_ip_preservation_enabled = true
    }
  }
}

# Data sources for account information
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
} 