# Output EKS cluster information for both regions

# US-West-2 Outputs
output "us_west_2_cluster_id" {
  description = "The name/id of the EKS cluster in us-west-2"
  value       = module.eks_us_west_2.cluster_id
}

output "us_west_2_cluster_name" {
  description = "The name of the EKS cluster in us-west-2"
  value       = module.eks_us_west_2.cluster_name
}

output "us_west_2_cluster_endpoint" {
  description = "Endpoint for the EKS cluster in us-west-2"
  value       = module.eks_us_west_2.cluster_endpoint
}

output "us_west_2_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for us-west-2 cluster"
  value       = module.eks_us_west_2.cluster_certificate_authority_data
  sensitive   = true
}

output "us_west_2_cluster_connection_command" {
  description = "Command to update kubeconfig for us-west-2 cluster access"
  value       = module.eks_us_west_2.cluster_connection_command
}

output "us_west_2_vpc_id" {
  description = "ID of the VPC in us-west-2"
  value       = module.eks_us_west_2.vpc_id
}

output "us_west_2_alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller in us-west-2"
  value       = module.eks_us_west_2.alb_controller_role_arn
}

output "us_west_2_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster in us-west-2"
  value       = module.eks_us_west_2.cluster_security_group_id
}

# US-East-1 Outputs
output "us_east_1_cluster_id" {
  description = "The name/id of the EKS cluster in us-east-1"
  value       = module.eks_us_east_1.cluster_id
}

output "us_east_1_cluster_name" {
  description = "The name of the EKS cluster in us-east-1"
  value       = module.eks_us_east_1.cluster_name
}

output "us_east_1_cluster_endpoint" {
  description = "Endpoint for the EKS cluster in us-east-1"
  value       = module.eks_us_east_1.cluster_endpoint
}

output "us_east_1_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for us-east-1 cluster"
  value       = module.eks_us_east_1.cluster_certificate_authority_data
  sensitive   = true
}

output "us_east_1_cluster_connection_command" {
  description = "Command to update kubeconfig for us-east-1 cluster access"
  value       = module.eks_us_east_1.cluster_connection_command
}

output "us_east_1_vpc_id" {
  description = "ID of the VPC in us-east-1"
  value       = module.eks_us_east_1.vpc_id
}

output "us_east_1_alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller in us-east-1"
  value       = module.eks_us_east_1.alb_controller_role_arn
}

output "us_east_1_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster in us-east-1"
  value       = module.eks_us_east_1.cluster_security_group_id
}

# Combined outputs for all regions
output "all_cluster_endpoints" {
  description = "Map of cluster endpoints by region"
  value = {
    us-west-2 = module.eks_us_west_2.cluster_endpoint
    us-east-1 = module.eks_us_east_1.cluster_endpoint
  }
}

output "all_cluster_names" {
  description = "Map of cluster names by region"
  value = {
    us-west-2 = module.eks_us_west_2.cluster_name
    us-east-1 = module.eks_us_east_1.cluster_name
  }
}

output "all_vpc_ids" {
  description = "Map of VPC IDs by region"
  value = {
    us-west-2 = module.eks_us_west_2.vpc_id
    us-east-1 = module.eks_us_east_1.vpc_id
  }
}

output "all_connection_commands" {
  description = "Map of kubectl connection commands by region"
  value = {
    us-west-2 = module.eks_us_west_2.cluster_connection_command
    us-east-1 = module.eks_us_east_1.cluster_connection_command
  }
} 