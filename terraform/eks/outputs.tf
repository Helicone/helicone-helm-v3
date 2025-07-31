# Output EKS cluster information

output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_connection_command" {
  description = "Command to update kubeconfig for cluster access"
  value       = module.eks_cluster.cluster_connection_command
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.eks_cluster.vpc_id
}

output "alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = module.eks_cluster.alb_controller_role_arn
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "region" {
  description = "AWS region where the cluster is deployed"
  value       = var.regions[0]
}

output "configured_regions" {
  description = "List of regions configured for deployment"
  value       = var.regions
}
