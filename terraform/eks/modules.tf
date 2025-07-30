# Multi-region EKS Cluster Modules

# Module for us-west-2 EKS cluster
module "eks_us_west_2" {
  source = "./modules/eks-cluster"
  
  # AWS Configuration
  region       = "us-west-2"
  cluster_name = "${var.cluster_name}"
  
  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
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
  valkey_cache_arn = try(var.valkey_cache_arns["us-west-2"], "")
  s3_bucket_arn    = try(var.s3_bucket_arns["us-west-2"], "")
  
  # Tags
  tags = merge(var.tags, {
    Region = "us-west-2"
  })

  # Provider configuration
  providers = {
    aws        = aws.us-west-2
    kubernetes = kubernetes.us-west-2
    helm       = helm.us-west-2
  }
}

# Module for us-east-1 EKS cluster
module "eks_us_east_1" {
  source = "./modules/eks-cluster"
  
  # AWS Configuration
  region       = "us-east-1"
  cluster_name = "${var.cluster_name}"
  
  # VPC Configuration
  vpc_cidr             = "10.1.0.0/16"
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  
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
  valkey_cache_arn = try(var.valkey_cache_arns["us-east-1"], "")
  s3_bucket_arn    = try(var.s3_bucket_arns["us-east-1"], "")
  
  # Tags
  tags = merge(var.tags, {
    Region = "us-east-1"
  })

  # Provider configuration
  providers = {
    aws        = aws.us-east-1
    kubernetes = kubernetes.us-east-1
    helm       = helm.us-east-1
  }
}

# Provider configuration for us-west-2
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

# Provider configuration for us-east-1
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# Kubernetes providers for each region
provider "kubernetes" {
  alias = "us-west-2"
  
  host                   = module.eks_us_west_2.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_us_west_2.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_us_west_2.cluster_name, "--region", "us-west-2"]
  }
}

provider "kubernetes" {
  alias = "us-east-1"
  
  host                   = module.eks_us_east_1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_us_east_1.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_us_east_1.cluster_name, "--region", "us-east-1"]
  }
}

# Helm providers for each region
provider "helm" {
  alias = "us-west-2"
  
  kubernetes {
    host                   = module.eks_us_west_2.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_us_west_2.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_us_west_2.cluster_name, "--region", "us-west-2"]
    }
  }
}

provider "helm" {
  alias = "us-east-1"
  
  kubernetes {
    host                   = module.eks_us_east_1.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_us_east_1.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_us_east_1.cluster_name, "--region", "us-east-1"]
    }
  }
}