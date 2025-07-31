# Multi-region EKS Cluster Modules

# Since Terraform requires static provider configuration,
# we'll use a different approach for multi-region deployment.
# Each region deployment will be handled by running terraform with different variables.

# The module expects to be called with specific region configuration
module "eks_cluster" {
  source = "./modules/eks-cluster"
  
  # AWS Configuration - will use the first region from the list
  region       = var.regions[0]
  cluster_name = "${var.cluster_name}"
  
  # VPC Configuration - use region-specific CIDR if available
  vpc_cidr = lookup(var.vpc_cidrs, var.regions[0], "10.0.0.0/16")
  
  # Calculate subnet CIDRs based on VPC CIDR
  private_subnet_cidrs = [
    cidrsubnet(lookup(var.vpc_cidrs, var.regions[0], "10.0.0.0/16"), 8, 1),
    cidrsubnet(lookup(var.vpc_cidrs, var.regions[0], "10.0.0.0/16"), 8, 2),
    cidrsubnet(lookup(var.vpc_cidrs, var.regions[0], "10.0.0.0/16"), 8, 3)
  ]
  public_subnet_cidrs = [
    cidrsubnet(lookup(var.vpc_cidrs, var.regions[0], "10.0.0.0/16"), 8, 101),
    cidrsubnet(lookup(var.vpc_cidrs, var.regions[0], "10.0.0.0/16"), 8, 102),
    cidrsubnet(lookup(var.vpc_cidrs, var.regions[0], "10.0.0.0/16"), 8, 103)
  ]
  
  # Node Configuration
  node_instance_types  = var.node_instance_types
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size
  
  # Kubernetes Configuration
  kubernetes_version = var.kubernetes_version
  
  # Endpoint Configuration
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs
  
  # Logging Configuration
  cluster_log_types = var.cluster_log_types
  
  # AWS Auth Configuration
  manage_aws_auth           = var.manage_aws_auth
  additional_aws_auth_roles = var.additional_aws_auth_roles
  additional_aws_auth_users = var.additional_aws_auth_users
  
  # Addon Configuration
  enable_alb_controller              = var.enable_alb_controller
  alb_controller_namespace           = var.alb_controller_namespace
  enable_pod_identity_agent          = var.enable_pod_identity_agent
  pod_identity_agent_version         = var.pod_identity_agent_version
  enable_nginx_ingress_controller    = var.enable_nginx_ingress_controller
  nginx_ingress_controller_namespace = var.nginx_ingress_controller_namespace
  enable_ingress_nginx_lb_lookup     = var.enable_ingress_nginx_lb_lookup
  
  # EKS Addon Versions
  vpc_cni_version        = var.vpc_cni_version
  coredns_version        = var.coredns_version
  kube_proxy_version     = var.kube_proxy_version
  ebs_csi_driver_version = var.ebs_csi_driver_version
  
  # Cluster Autoscaler
  enable_cluster_autoscaler        = var.enable_cluster_autoscaler
  cluster_autoscaler_policy_arn    = var.cluster_autoscaler_policy_arn
  
  # AI Gateway Configuration
  valkey_cache_arn = try(var.valkey_cache_arns[var.regions[0]], "")
  s3_bucket_arn    = try(var.s3_bucket_arns[var.regions[0]], "")
  
  # Tags
  tags = merge(var.tags, {
    Region = var.regions[0]
  })
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name, "--region", var.regions[0]]
  }
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name, "--region", var.regions[0]]
    }
  }
}