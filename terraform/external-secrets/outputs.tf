#################################################################################
# AWS Secrets Manager Outputs
#################################################################################

output "database_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.database.arn
}

output "database_secret_name" {
  description = "Name of the database credentials secret"
  value       = aws_secretsmanager_secret.database.name
}

output "storage_secret_arn" {
  description = "ARN of the storage credentials secret"
  value       = aws_secretsmanager_secret.storage.arn
}

output "storage_secret_name" {
  description = "Name of the storage credentials secret"
  value       = aws_secretsmanager_secret.storage.name
}

output "web_secret_arn" {
  description = "ARN of the web application secrets"
  value       = aws_secretsmanager_secret.web.arn
}

output "web_secret_name" {
  description = "Name of the web application secrets"
  value       = aws_secretsmanager_secret.web.name
}

output "ai_gateway_secret_arn" {
  description = "ARN of the AI Gateway API keys secret"
  value       = var.create_ai_gateway_secrets ? aws_secretsmanager_secret.ai_gateway[0].arn : null
}

output "ai_gateway_secret_name" {
  description = "Name of the AI Gateway API keys secret"
  value       = var.create_ai_gateway_secrets ? aws_secretsmanager_secret.ai_gateway[0].name : null
}

output "clickhouse_secret_arn" {
  description = "ARN of the ClickHouse credentials secret"
  value       = var.create_clickhouse_secrets ? aws_secretsmanager_secret.clickhouse[0].arn : null
}

output "clickhouse_secret_name" {
  description = "Name of the ClickHouse credentials secret"
  value       = var.create_clickhouse_secrets ? aws_secretsmanager_secret.clickhouse[0].name : null
}

output "ai_gateway_api_keys_secret_arn" {
  description = "ARN of the AI Gateway API keys secret"
  value       = aws_secretsmanager_secret.ai_gateway_api_keys.arn
}

output "ai_gateway_api_keys_secret_name" {
  description = "Name of the AI Gateway API keys secret"
  value       = aws_secretsmanager_secret.ai_gateway_api_keys.name
}

output "external_clickhouse_secret_arn" {
  description = "ARN of the external ClickHouse credentials secret"
  value       = aws_secretsmanager_secret.external_clickhouse.arn
}

output "external_clickhouse_secret_name" {
  description = "Name of the external ClickHouse credentials secret"
  value       = aws_secretsmanager_secret.external_clickhouse.name
}

#################################################################################
# IAM Resources
#################################################################################

output "external_secrets_role_arn" {
  description = "ARN of the IAM role for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_role_name" {
  description = "Name of the IAM role for External Secrets Operator"
  value       = aws_iam_role.external_secrets.name
}

#################################################################################
# KMS Resources
#################################################################################

output "kms_key_arn" {
  description = "ARN of the KMS key for secrets encryption"
  value       = var.create_kms_key ? aws_kms_key.secrets[0].arn : null
}

output "kms_key_id" {
  description = "ID of the KMS key for secrets encryption"
  value       = var.create_kms_key ? aws_kms_key.secrets[0].key_id : null
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = var.create_kms_key ? aws_kms_alias.secrets[0].name : null
}

#################################################################################
# Helper Information
#################################################################################

output "secret_prefix" {
  description = "Prefix used for all secrets"
  value       = var.secret_prefix
}

output "region" {
  description = "AWS region where resources are created"
  value       = var.region
}

#################################################################################
# AWS CLI Commands for Secret Management
#################################################################################

output "secret_update_commands" {
  description = "AWS CLI commands to update secrets manually"
  value = {
    database   = "aws secretsmanager update-secret --secret-id ${aws_secretsmanager_secret.database.name} --secret-string '{\"username\":\"postgres\",\"password\":\"your-password\",\"database\":\"helicone_test\"}'"
    storage    = "aws secretsmanager update-secret --secret-id ${aws_secretsmanager_secret.storage.name} --secret-string '{\"access_key\":\"your-access-key\",\"secret_key\":\"your-secret-key\",\"minio-root-user\":\"your-user\",\"minio-root-password\":\"your-password\"}'"
    web        = "aws secretsmanager update-secret --secret-id ${aws_secretsmanager_secret.web.name} --secret-string '{\"BETTER_AUTH_SECRET\":\"your-secret\",\"STRIPE_SECRET_KEY\":\"sk_...\"}'"
    ai_gateway = var.create_ai_gateway_secrets ? "aws secretsmanager update-secret --secret-id ${aws_secretsmanager_secret.ai_gateway[0].name} --secret-string '{\"AI_GATEWAY__DATABASE__URL\":\"postgresql://...\",\"PGSSLROOTCERT\":\"...\",\"AI_GATEWAY__MINIO__ACCESS_KEY\":\"...\",\"AI_GATEWAY__MINIO__SECRET_KEY\":\"...\"}'" : null
    ai_gateway_api_keys = "aws secretsmanager update-secret --secret-id ${aws_secretsmanager_secret.ai_gateway_api_keys.name} --secret-string '{\"openai_api_key\":\"sk-...\",\"anthropic_api_key\":\"sk-...\",\"gemini_api_key\":\"your-key\",\"helicone_api_key\":\"your-key\"}'"
    clickhouse = var.create_clickhouse_secrets ? "aws secretsmanager update-secret --secret-id ${aws_secretsmanager_secret.clickhouse[0].name} --secret-string '{\"user\":\"default\",\"password\":\"your-password\"}'" : null
    external_clickhouse = "aws secretsmanager update-secret --secret-id ${aws_secretsmanager_secret.external_clickhouse.name} --secret-string '{\"username\":\"default\",\"password\":\"your-password\"}'"
  }
  sensitive = true
}
