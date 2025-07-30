# Data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
}

#################################################################################
# AWS Secrets Manager Secrets
#################################################################################

# Database secrets
resource "aws_secretsmanager_secret" "database" {
  name                    = "${var.secret_prefix}/database"
  description             = "Helicone database credentials"
  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = var.database_secrets.username
    password = var.database_secrets.password
    database = var.database_secrets.database
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Storage secrets (S3/MinIO)
resource "aws_secretsmanager_secret" "storage" {
  name                    = "${var.secret_prefix}/storage"
  description             = "Helicone storage credentials (S3/MinIO)"
  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "storage" {
  secret_id = aws_secretsmanager_secret.storage.id
  secret_string = jsonencode({
    access_key          = var.storage_secrets.access_key
    secret_key          = var.storage_secrets.secret_key
    minio-root-user     = var.storage_secrets.minio_root_user
    minio-root-password = var.storage_secrets.minio_root_password
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Web application secrets
resource "aws_secretsmanager_secret" "web" {
  name                    = "${var.secret_prefix}/web"
  description             = "Helicone web application secrets"
  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "web" {
  secret_id = aws_secretsmanager_secret.web.id
  secret_string = jsonencode({
    BETTER_AUTH_SECRET = var.web_secrets.better_auth_secret
    STRIPE_SECRET_KEY  = var.web_secrets.stripe_secret_key
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# AI Gateway API keys
resource "aws_secretsmanager_secret" "ai_gateway" {
  count = var.create_ai_gateway_secrets ? 1 : 0

  name                    = "${var.secret_prefix}/ai-gateway"
  description             = "Helicone AI Gateway API keys"
  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "ai_gateway" {
  count = var.create_ai_gateway_secrets ? 1 : 0

  secret_id = aws_secretsmanager_secret.ai_gateway[0].id
  secret_string = jsonencode({
    openai_api_key    = var.ai_gateway_secrets.openai_api_key
    anthropic_api_key = var.ai_gateway_secrets.anthropic_api_key
    gemini_api_key    = var.ai_gateway_secrets.gemini_api_key
    helicone_api_key  = var.ai_gateway_secrets.helicone_api_key
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ClickHouse secrets
resource "aws_secretsmanager_secret" "clickhouse" {
  count = var.create_clickhouse_secrets ? 1 : 0

  name                    = "${var.secret_prefix}/clickhouse"
  description             = "Helicone ClickHouse credentials"
  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "clickhouse" {
  count = var.create_clickhouse_secrets ? 1 : 0

  secret_id = aws_secretsmanager_secret.clickhouse[0].id
  secret_string = jsonencode({
    user = var.clickhouse_secrets.user
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

#################################################################################
# IAM Role for External Secrets Operator (Pod Identity)
#################################################################################

# Trust policy for External Secrets Operator using Pod Identity
data "aws_iam_policy_document" "external_secrets_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole", "sts:TagSession"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:cluster-name"
      values   = [var.eks_cluster_name]
    }
  }
}

# IAM role for External Secrets Operator
resource "aws_iam_role" "external_secrets" {
  name               = "${var.resource_prefix}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_trust.json
  description        = "IAM role for External Secrets Operator to access AWS Secrets Manager via Pod Identity"

  tags = var.tags
}

# IAM policy for External Secrets Operator
data "aws_iam_policy_document" "external_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      aws_secretsmanager_secret.database.arn,
      aws_secretsmanager_secret.storage.arn,
      aws_secretsmanager_secret.web.arn,
    ]
  }

  # Optional AI Gateway secrets
  dynamic "statement" {
    for_each = var.create_ai_gateway_secrets ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      resources = [
        aws_secretsmanager_secret.ai_gateway[0].arn
      ]
    }
  }

  # Optional ClickHouse secrets  
  dynamic "statement" {
    for_each = var.create_clickhouse_secrets ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      resources = [
        aws_secretsmanager_secret.clickhouse[0].arn
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "external_secrets" {
  name   = "${var.resource_prefix}-external-secrets-policy"
  role   = aws_iam_role.external_secrets.id
  policy = data.aws_iam_policy_document.external_secrets_policy.json
}

#################################################################################
# Optional KMS Key for Secret Encryption
#################################################################################

resource "aws_kms_key" "secrets" {
  count = var.create_kms_key ? 1 : 0

  description              = "KMS key for Helicone secrets encryption"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_deletion_window_days

  tags = var.tags
}

resource "aws_kms_alias" "secrets" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.resource_prefix}-secrets"
  target_key_id = aws_kms_key.secrets[0].key_id
}

#################################################################################
# EKS Pod Identity Association for External Secrets Operator
#################################################################################

# Pod Identity Association for External Secrets Operator in helicone-infrastructure namespace
resource "aws_eks_pod_identity_association" "external_secrets_helicone_infrastructure" {
  cluster_name    = var.eks_cluster_name
  namespace       = "helicone-infrastructure"
  service_account = "helicone-infrastructure-external-secrets"
  role_arn        = aws_iam_role.external_secrets.arn

  tags = var.tags
}

# Pod Identity Association for External Secrets Operator in external-secrets namespace
resource "aws_eks_pod_identity_association" "external_secrets_external_secrets" {
  cluster_name    = var.eks_cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external_secrets.arn

  tags = var.tags
}

# Pod Identity Association for External Secrets Operator in helicone namespace
resource "aws_eks_pod_identity_association" "external_secrets_helicone" {
  cluster_name    = var.eks_cluster_name
  namespace       = "helicone"
  service_account = "external-secrets-sa"
  role_arn        = aws_iam_role.external_secrets.arn

  tags = var.tags
} 