variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "helm-request-response-storage"
}

variable "region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment tag for the S3 bucket"
  type        = string
  default     = "production"
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for the S3 bucket"
  type        = map(string)
  default     = {}
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["https://heliconetest.com"]
}

variable "cors_allowed_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET"]
}

variable "cors_allowed_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_expose_headers" {
  description = "List of headers to expose in CORS responses"
  type        = list(string)
  default     = ["ETag"]
}

variable "cors_max_age_seconds" {
  description = "Maximum age in seconds for CORS preflight requests"
  type        = number
  default     = 3000
}

# Service Account Access Configuration
variable "enable_service_account_access" {
  description = "Enable IAM roles for service accounts via Pod Identity Agent for S3 access"
  type        = bool
  default     = false
}

variable "eks_cluster_name" {
  description = "EKS cluster name for Pod Identity Agent access"
  type        = string
  default     = ""
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace where the service accounts will be created"
  type        = string
  default     = "helicone"
} 