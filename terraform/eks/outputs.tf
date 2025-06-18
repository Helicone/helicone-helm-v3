output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  description = "Version of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_platform_version" {
  description = "Platform version of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.platform_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for the EKS cluster"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.eks_nodes.id
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.eks_nodes.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.eks_nodes.status
}

output "node_group_role_arn" {
  description = "ARN of the IAM role for the node group"
  value       = aws_iam_role.eks_node_role.arn
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
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

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the IAM role for the EBS CSI driver"
  value       = var.enable_ebs_csi_driver ? aws_iam_role.ebs_csi_driver[0].arn : null
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the IAM role for the cluster autoscaler"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : null
}

output "kubectl_config" {
  description = "kubectl config command to update local kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.eks_cluster.name}"
}

# ACM Certificate outputs
output "certificate_arn" {
  description = "ARN of the ACM certificate for heliconetest.com"
  value       = aws_acm_certificate_validation.helicone_cert.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = aws_acm_certificate.helicone_cert.domain_name
}

# ACM Certificate outputs for helicone-test.com
output "certificate_helicone_test_arn" {
  description = "ARN of the ACM certificate for helicone-test.com"
  value       = var.enable_helicone_test_domain ? aws_acm_certificate.helicone_test_cert[0].arn : null
}

output "certificate_helicone_test_domain_name" {
  description = "Domain name of the ACM certificate for helicone-test.com"
  value       = var.enable_helicone_test_domain ? aws_acm_certificate.helicone_test_cert[0].domain_name : null
}

output "certificate_helicone_test_validation_options" {
  description = "Certificate validation options for helicone-test.com (to be added to Cloudflare)"
  value       = var.enable_helicone_test_domain ? aws_acm_certificate.helicone_test_cert[0].domain_validation_options : null
  sensitive   = false
}



# ACM Certificate outputs for helicone.ai
output "certificate_helicone_ai_arn" {
  description = "ARN of the ACM certificate for helicone.ai"
  value       = aws_acm_certificate.helicone_ai_cert.arn
}

output "certificate_helicone_ai_domain_name" {
  description = "Domain name of the ACM certificate for helicone.ai"
  value       = aws_acm_certificate.helicone_ai_cert.domain_name
}

output "certificate_helicone_ai_validation_options" {
  description = "Certificate validation options for helicone.ai (to be added to Cloudflare)"
  value       = aws_acm_certificate.helicone_ai_cert.domain_validation_options
  sensitive   = false
}



# Load balancer hostname for Cloudflare DNS records
output "load_balancer_hostname" {
  description = "Load balancer hostname for Cloudflare DNS records"
  value       = try(data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname, null)
} 