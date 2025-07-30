output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC issuer"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = aws_eks_cluster.eks_cluster.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.status
}

output "cluster_version" {
  description = "Kubernetes server version for the cluster"
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "vpc_id" {
  description = "ID of the VPC where the cluster and workers are deployed"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "node_group_id" {
  description = "EKS node group id"
  value       = aws_eks_node_group.eks_nodes.id
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.eks_nodes.arn
}

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = aws_eks_node_group.eks_nodes.status
}

output "node_group_asg_names" {
  description = "Names of the Auto Scaling Groups associated with the EKS Node Group"
  value       = aws_eks_node_group.eks_nodes.resources[0].autoscaling_groups[*].name
}

output "region" {
  description = "AWS region"
  value       = var.region
}

# AWS Load Balancer Controller Outputs
output "alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = var.enable_alb_controller ? aws_iam_role.alb_controller_role[0].arn : null
}

# NGINX Ingress Controller Outputs
output "nginx_ingress_controller_role_arn" {
  description = "ARN of the IAM role for NGINX Ingress Controller"
  value       = var.enable_nginx_ingress_controller ? aws_iam_role.nginx_ingress_controller_role[0].arn : null
}

# Export key information needed for connecting to the cluster
output "cluster_connection_command" {
  description = "Command to update kubeconfig for cluster access"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.eks_cluster.name}"
}

# Service Account Names for Pod Identity
output "ai_gateway_service_account_name" {
  description = "Service account name expected for AI Gateway Pod Identity association"
  value       = "${var.cluster_name}-${var.region}-ai-gateway-sa"
}

output "alb_controller_service_account_name" {
  description = "Service account name expected for ALB Controller Pod Identity association"
  value       = "${var.cluster_name}-${var.region}-alb-controller-sa"
}