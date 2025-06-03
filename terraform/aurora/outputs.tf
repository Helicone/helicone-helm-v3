# Aurora Cluster Outputs
output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = aws_rds_cluster.aurora_cluster.id
}

output "cluster_identifier" {
  description = "The RDS Cluster Identifier"
  value       = aws_rds_cluster.aurora_cluster.cluster_identifier
}

output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "cluster_port" {
  description = "The port on which the DB accepts connections"
  value       = aws_rds_cluster.aurora_cluster.port
}

output "cluster_master_username" {
  description = "The master username for the RDS cluster"
  value       = aws_rds_cluster.aurora_cluster.master_username
}

output "cluster_database_name" {
  description = "The name of the database"
  value       = aws_rds_cluster.aurora_cluster.database_name
}

output "cluster_hosted_zone_id" {
  description = "The hosted zone ID of the Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.hosted_zone_id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = aws_rds_cluster.aurora_cluster.cluster_resource_id
}

output "cluster_arn" {
  description = "The ARN of the RDS cluster"
  value       = aws_rds_cluster.aurora_cluster.arn
}

# Instance Outputs
output "instance_ids" {
  description = "List of RDS instance IDs"
  value       = aws_rds_cluster_instance.aurora_instances[*].id
}

output "instance_arns" {
  description = "List of RDS instance ARNs"
  value       = aws_rds_cluster_instance.aurora_instances[*].arn
}

output "instance_endpoints" {
  description = "List of RDS instance endpoints"
  value       = aws_rds_cluster_instance.aurora_instances[*].endpoint
}

# Security Group Outputs
output "security_group_id" {
  description = "The ID of the security group for Aurora"
  value       = aws_security_group.aurora_sg.id
}

output "security_group_arn" {
  description = "The ARN of the security group for Aurora"
  value       = aws_security_group.aurora_sg.arn
}

# Subnet Group Output
output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.aurora_subnet_group.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group"
  value       = aws_db_subnet_group.aurora_subnet_group.arn
}

# Parameter Group Outputs
output "cluster_parameter_group_name" {
  description = "The name of the cluster parameter group"
  value       = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.name
}

output "instance_parameter_group_name" {
  description = "The name of the instance parameter group"
  value       = aws_db_parameter_group.aurora_instance_parameter_group.name
}

# KMS Key Outputs
output "kms_key_id" {
  description = "The KMS key ID used for encryption"
  value       = aws_kms_key.aurora_kms_key.key_id
}

output "kms_key_arn" {
  description = "The KMS key ARN used for encryption"
  value       = aws_kms_key.aurora_kms_key.arn
}

output "kms_alias_name" {
  description = "The KMS key alias name"
  value       = aws_kms_alias.aurora_kms_alias.name
}

# Secrets Manager Outputs
output "secrets_manager_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the master password"
  value       = aws_secretsmanager_secret.aurora_master_password.arn
}

output "secrets_manager_secret_name" {
  description = "The name of the Secrets Manager secret containing the master password"
  value       = aws_secretsmanager_secret.aurora_master_password.name
}

# Enhanced Monitoring Role Output
output "enhanced_monitoring_role_arn" {
  description = "The ARN of the enhanced monitoring role"
  value       = var.enable_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
}

# Connection Information (for applications)
output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${aws_rds_cluster.aurora_cluster.master_username}@${aws_rds_cluster.aurora_cluster.endpoint}:${aws_rds_cluster.aurora_cluster.port}/${aws_rds_cluster.aurora_cluster.database_name}"
  sensitive   = false
}

output "database_users" {
  description = "Database users created (passwords stored in Secrets Manager)"
  value = {
    for k, v in postgresql_role.app_users : k => {
      username = v.name
      databases = var.database_users[k].databases
      privileges = var.database_users[k].privileges
    }
  }
}

output "additional_databases" {
  description = "Additional databases created in the Aurora cluster"
  value       = [for db in postgresql_database.additional_databases : db.name]
}

output "connection_examples" {
  description = "Example connection strings for different databases"
  value = {
    primary_database = "postgresql://${aws_rds_cluster.aurora_cluster.master_username}:PASSWORD@${aws_rds_cluster.aurora_cluster.endpoint}:${aws_rds_cluster.aurora_cluster.port}/${aws_rds_cluster.aurora_cluster.database_name}"
    additional_databases = {
      for db_name in var.additional_databases :
      db_name => "postgresql://USERNAME:PASSWORD@${aws_rds_cluster.aurora_cluster.endpoint}:${aws_rds_cluster.aurora_cluster.port}/${db_name}"
    }
  }
} 