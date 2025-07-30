output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.helm_request_response_storage.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.helm_request_response_storage.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.helm_request_response_storage.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.helm_request_response_storage.bucket_regional_domain_name
}

output "bucket_region" {
  description = "Region where the S3 bucket is deployed"
  value       = aws_s3_bucket.helm_request_response_storage.region
}

output "s3_service_account_role_arn" {
  description = "ARN of the IAM role for service account access to S3"
  value       = var.enable_service_account_access ? aws_iam_role.s3_service_account[0].arn : null
}

output "pod_identity_associations" {
  description = "Map of Pod Identity Association IDs"
  value = var.enable_service_account_access ? {
    helicone_core_web           = aws_eks_pod_identity_association.helicone_core_web[0].association_id
    helicone_core_jawn          = aws_eks_pod_identity_association.helicone_core_jawn[0].association_id  
    helicone_ai_gateway         = aws_eks_pod_identity_association.helicone_ai_gateway[0].association_id
    helicone_us_east_1_ai_gateway = aws_eks_pod_identity_association.helicone_us_east_1_ai_gateway[0].association_id
  } : null
} 