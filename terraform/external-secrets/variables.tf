#################################################################################
# General Configuration
#################################################################################

variable "region" {
  description = "AWS region where resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.region))
    error_message = "AWS region must be a valid region identifier."
  }
}

variable "resource_prefix" {
  description = "Prefix for AWS resource names"
  type        = string
  default     = "helicone"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "secret_prefix" {
  description = "Prefix for secret names in AWS Secrets Manager"
  type        = string
  default     = "helicone"

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_+=.@-]+$", var.secret_prefix))
    error_message = "Secret prefix must contain only valid AWS Secrets Manager characters."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Helicone"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

variable "recovery_window_days" {
  description = "Number of days AWS Secrets Manager waits before deleting a secret"
  type        = number
  default     = 7

  validation {
    condition     = var.recovery_window_days >= 7 && var.recovery_window_days <= 30
    error_message = "Recovery window must be between 7 and 30 days."
  }
}

#################################################################################
# EKS Configuration
#################################################################################

variable "eks_cluster_name" {
  description = "Name of the EKS cluster for Pod Identity Association"
  type        = string

  validation {
    condition     = length(var.eks_cluster_name) > 0
    error_message = "EKS cluster name cannot be empty."
  }
}

#################################################################################
# Secret Values
#################################################################################

variable "database_secrets" {
  description = "Database secret values for CloudNativePG"
  type = object({
    username = string
    password = string
    database = string
  })
  sensitive = true

  validation {
    condition     = length(var.database_secrets.password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }

  validation {
    condition     = length(var.database_secrets.username) > 0
    error_message = "Database username cannot be empty."
  }

  validation {
    condition     = var.database_secrets.username == "helicone"
    error_message = "Database username must be 'helicone' to match Helm chart expectations."
  }

  validation {
    condition     = length(var.database_secrets.database) > 0
    error_message = "Database name cannot be empty."
  }
}

variable "storage_secrets" {
  description = "Storage secret values (S3/MinIO)"
  type = object({
    access_key          = string
    secret_key          = string
    minio_root_user     = string
    minio_root_password = string
  })
  sensitive = true

  validation {
    condition     = length(var.storage_secrets.access_key) > 0
    error_message = "Storage access key cannot be empty."
  }

  validation {
    condition     = length(var.storage_secrets.secret_key) > 0
    error_message = "Storage secret key cannot be empty."
  }

  validation {
    condition     = length(var.storage_secrets.minio_root_password) >= 8
    error_message = "MinIO root password must be at least 8 characters long."
  }
}

variable "web_secrets" {
  description = "Web application secret values"
  type = object({
    better_auth_secret = string
    stripe_secret_key  = string
  })
  sensitive = true

  validation {
    condition     = length(var.web_secrets.better_auth_secret) >= 32
    error_message = "Better Auth secret must be at least 32 characters long."
  }
}

variable "create_ai_gateway_secrets" {
  description = "Whether to create AI Gateway secrets in AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "ai_gateway_secrets" {
  description = "AI Gateway cloud secrets for ECS deployment"
  type = object({
    # Cloud secrets for ECS deployment
    database_url      = string
    pg_ssl_root_cert  = string
    minio_access_key  = string
    minio_secret_key  = string
  })
  default = {
    database_url      = ""
    pg_ssl_root_cert  = ""
    minio_access_key  = ""
    minio_secret_key  = ""
  }
  sensitive = true
}

variable "create_clickhouse_secrets" {
  description = "Whether to create ClickHouse secrets in AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "clickhouse_secrets" {
  description = "ClickHouse secret values"
  type = object({
    user     = string
    password = string
  })
  default = {
    user     = "default"
    password = "your-clickhouse-password"
  }
  sensitive = true
}

#################################################################################
# KMS Configuration
#################################################################################

variable "create_kms_key" {
  description = "Whether to create a KMS key for secret encryption"
  type        = bool
  default     = false
}

variable "kms_deletion_window_days" {
  description = "Number of days to wait before deleting KMS key"
  type        = number
  default     = 10

  validation {
    condition     = var.kms_deletion_window_days >= 7 && var.kms_deletion_window_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
} 