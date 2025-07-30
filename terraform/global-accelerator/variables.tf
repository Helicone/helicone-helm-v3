variable "accelerator_name" {
  description = "Name of the Global Accelerator"
  type        = string
  default     = "helicone-global-accelerator"
}

variable "environment" {
  description = "Environment tag for the Global Accelerator"
  type        = string
  default     = "production"
}

variable "ip_address_type" {
  description = "The IP address type for the Global Accelerator (IPV4 or DUAL_STACK)"
  type        = string
  default     = "IPV4"
  validation {
    condition     = contains(["IPV4", "DUAL_STACK"], var.ip_address_type)
    error_message = "IP address type must be either IPV4 or DUAL_STACK."
  }
}

variable "enabled" {
  description = "Whether the Global Accelerator is enabled"
  type        = bool
  default     = true
}

variable "client_affinity" {
  description = "Client affinity for the listener (NONE or SOURCE_IP)"
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["NONE", "SOURCE_IP"], var.client_affinity)
    error_message = "Client affinity must be either NONE or SOURCE_IP."
  }
}

variable "flow_logs_enabled" {
  description = "Enable flow logs for the Global Accelerator"
  type        = bool
  default     = false
}

variable "flow_logs_s3_bucket" {
  description = "S3 bucket name for flow logs"
  type        = string
  default     = ""
}

variable "flow_logs_s3_prefix" {
  description = "S3 prefix for flow logs"
  type        = string
  default     = "global-accelerator-logs/"
}

variable "endpoint_regions" {
  description = "Map of regions with their ALB ARNs and traffic percentages"
  type = map(object({
    alb_arns           = list(string)
    traffic_percentage = number
  }))
  default = {
    "us-east-1" = {
      alb_arns           = []
      traffic_percentage = 100
    }
    "us-west-2" = {
      alb_arns           = []
      traffic_percentage = 100
    }
  }
  validation {
    condition = alltrue([
      for region, config in var.endpoint_regions : 
      config.traffic_percentage >= 0 && config.traffic_percentage <= 100
    ])
    error_message = "Traffic percentage must be between 0 and 100 for all regions."
  }
}

variable "health_check_interval_seconds" {
  description = "The time in seconds between health checks"
  type        = number
  default     = 30
  validation {
    condition     = var.health_check_interval_seconds >= 10 && var.health_check_interval_seconds <= 30
    error_message = "Health check interval must be between 10 and 30 seconds."
  }
}

variable "health_check_path" {
  description = "The path for health checks"
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "The protocol for health checks (HTTP or HTTPS)"
  type        = string
  default     = "HTTPS"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.health_check_protocol)
    error_message = "Health check protocol must be either HTTP or HTTPS."
  }
}

variable "health_check_port" {
  description = "The port for health checks"
  type        = number
  default     = 443
}

variable "threshold_count" {
  description = "The number of consecutive health checks to determine endpoint health"
  type        = number
  default     = 3
  validation {
    condition     = var.threshold_count >= 1 && var.threshold_count <= 10
    error_message = "Threshold count must be between 1 and 10."
  }
}

variable "endpoint_weight" {
  description = "Weight for each endpoint"
  type        = number
  default     = 100
  validation {
    condition     = var.endpoint_weight >= 0 && var.endpoint_weight <= 255
    error_message = "Endpoint weight must be between 0 and 255."
  }
}

variable "port_overrides" {
  description = "List of port overrides for the endpoint groups"
  type = list(object({
    listener_port = number
    endpoint_port = number
  }))
  default = []
}

variable "tags" {
  description = "Additional tags for the Global Accelerator"
  type        = map(string)
  default     = {}
} 