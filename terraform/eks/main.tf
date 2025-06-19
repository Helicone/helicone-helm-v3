provider "aws" {
  region = var.region
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-cluster-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# VPC for EKS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = concat(module.vpc.private_subnets, module.vpc.public_subnets)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.cluster_log_types

  encryption_config {
    provider {
      key_arn = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.eks[0].arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]

  tags = var.tags
}

# KMS Key for EKS encryption (optional)
resource "aws_kms_key" "eks" {
  count                   = var.kms_key_arn == "" ? 1 : 0
  description             = "EKS Secret Encryption Key for ${var.cluster_name}"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eks-key"
  })
}

resource "aws_kms_alias" "eks" {
  count         = var.kms_key_arn == "" ? 1 : 0
  name          = "alias/${var.cluster_name}-eks"
  target_key_id = aws_kms_key.eks[0].key_id
}

# IAM Role for Node Group
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_driver_policy" {
  count      = var.enable_ebs_csi_driver ? 1 : 0
  policy_arn = var.ebs_csi_driver_policy_arn != "" ? var.ebs_csi_driver_policy_arn : aws_iam_policy.ebs_csi_driver[0].arn
  role       = aws_iam_role.eks_node_role.name
}

# EKS Node Group
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnets

  instance_types = var.node_instance_types
  capacity_type  = var.node_capacity_type
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Enable auto-scaling group tags
  tags = merge(var.tags, {
    "k8s.io/cluster-autoscaler/enabled"         = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

# OIDC Provider for EKS
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}

# Get the load balancer from Kubernetes (for other modules like route53-acm and cloudflare)
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodes
  ]
} 