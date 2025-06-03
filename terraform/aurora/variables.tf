variable "cluster_identifier" {
  description = "The cluster identifier for Aurora PostgreSQL"
  type        = string
  default     = "helicone-aurora-cluster"
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
  default     = "helicone"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "helicone_admin"
}

variable "master_password" {
  description = "Password for the master DB user. If not provided, a random password will be generated"
  type        = string
  default     = null
  sensitive   = true
}

variable "engine_version" {
  description = "The engine version for Aurora PostgreSQL"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "The instance class for Aurora instances"
  type        = string
  default     = "db.r6g.large"
}

variable "instance_count" {
  description = "Number of instances in the Aurora cluster"
  type        = number
  default     = 2
}

variable "backup_retention_period" {
  description = "The backup retention period in days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "vpc_id" {
  description = "ID of the VPC where Aurora will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Aurora cluster"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access Aurora"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Aurora"
  type        = list(string)
  default     = []
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB cluster should have deletion protection enabled"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring for Aurora instances"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "The interval for collecting enhanced monitoring metrics"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights for Aurora instances"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

# Variables for additional database management
variable "additional_databases" {
  description = "List of additional database names to create in the Aurora cluster"
  type        = list(string)
  default     = []
}

variable "database_users" {
  description = "Map of database users to create with their configuration"
  type = map(object({
    password    = string
    databases   = list(string)
    privileges  = list(string)
  }))
  default = {}
} 