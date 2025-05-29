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