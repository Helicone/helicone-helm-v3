# Get current AWS account ID
data "aws_caller_identity" "current" {}

# IAM role for AI Gateway EKS Pod
resource "aws_iam_role" "ai_gateway_pod_identity_role" {
  name = "${var.cluster_name}-${var.region}-ai-gateway-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "ai-gateway-pod-identity-role"
  })
}

# IAM policy for ElastiCache and S3 access
resource "aws_iam_policy" "ai_gateway_iam_policy" {
  name        = "${var.cluster_name}-${var.region}-ai-gateway-iam-policy"
  description = "Policy for AI Gateway EKS Pod to access ElastiCache and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # ElastiCache permissions - only if valkey_cache_arn is provided
      var.valkey_cache_arn != "" ? [{
        Effect = "Allow"
        Action = [
          "elasticache:DescribeCacheClusters",
          "elasticache:DescribeReplicationGroups", 
          "elasticache:DescribeServerlessCaches",
          "elasticache:Connect"
        ]
        Resource = [
          var.valkey_cache_arn
        ]
      }] : [],
      # S3 object permissions
      [{
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      }]
    )
  })

  tags = merge(var.tags, {
    Name = "ai-gateway-iam-policy"
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "gateway_policy_attachment" {
  role       = aws_iam_role.ai_gateway_pod_identity_role.name
  policy_arn = aws_iam_policy.ai_gateway_iam_policy.arn
}

# EKS Pod Identity Association for AI Gateway
resource "aws_eks_pod_identity_association" "ai_gateway_association" {
  count           = 1
  cluster_name    = var.cluster_name
  namespace       = var.ai_gateway_namespace
  service_account = "${var.cluster_name}-${var.region}-ai-gateway-sa"
  role_arn        = aws_iam_role.ai_gateway_pod_identity_role.arn

  tags = var.tags
}
