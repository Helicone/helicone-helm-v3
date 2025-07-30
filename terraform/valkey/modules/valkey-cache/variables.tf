variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "valkey_cache_name" {
  description = "Name of the Valkey serverless cache"
  type        = string
}

variable "description" {
  description = "Description for the Valkey cache"
  type        = string
  default     = "Helicone Valkey serverless cache for caching and rate limiting"
}

variable "engine" {
  description = "The engine type (valkey)"
  type        = string
  default     = "valkey"

  validation {
    condition     = contains(["valkey"], var.engine)
    error_message = "Engine must be 'valkey' for serverless cache."
  }
}

variable "major_engine_version" {
  description = "The major engine version for Valkey"
  type        = string
  default     = "8"
}

variable "max_storage_gb" {
  description = "Maximum storage capacity in GB"
  type        = number
  default     = 1

  validation {
    condition     = var.max_storage_gb >= 1 && var.max_storage_gb <= 5000
    error_message = "Maximum storage must be between 1 and 5000 GB."
  }
}

variable "max_ecpu_per_second" {
  description = "Maximum ECPUs per second"
  type        = number
  default     = 1000

  validation {
    condition     = var.max_ecpu_per_second >= 1000 && var.max_ecpu_per_second <= 15000000
    error_message = "Maximum ECPUs per second must be between 1,000 and 15,000,000."
  }
}

variable "daily_snapshot_time" {
  description = "Daily snapshot time in 24-hour format (UTC)"
  type        = string
  default     = "05:00"

  validation {
    condition     = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.daily_snapshot_time))
    error_message = "Daily snapshot time must be in HH:MM format (24-hour UTC)."
  }
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 1

  validation {
    condition     = var.snapshot_retention_limit >= 1 && var.snapshot_retention_limit <= 35
    error_message = "Snapshot retention limit must be between 1 and 35 days."
  }
}

variable "vpc_id" {
  description = "VPC ID where the cache will be created. If empty, uses default VPC"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cache subnet group. If empty, uses default VPC subnets"
  type        = list(string)
  default     = []
}

variable "create_subnet_group" {
  description = "Whether to create a subnet group for the cache"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the cache"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access the cache"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}