variable "regions" {
  description = "List of AWS regions to deploy EKS clusters"
  type        = list(string)
  default     = ["us-west-2", "us-east-1"]
}

variable "region" {
  description = "Default AWS region (for backwards compatibility)"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "helicone"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"  # Update to 1.32 when available in your region
}

variable "vpc_cidrs" {
  description = "Map of CIDR blocks for VPCs by region"
  type        = map(string)
  default = {
    "us-west-2" = "10.0.0.0/16"
    "us-east-1" = "10.1.0.0/16"
    "eu-west-1" = "10.2.0.0/16"
    "ap-southeast-1" = "10.3.0.0/16"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (deprecated, use vpc_cidrs)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "List of cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "node_instance_types" {
  description = "Instance types for the node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_capacity_type" {
  description = "Capacity type for the node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 100
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "kms_key_arn" {
  description = "ARN of existing KMS key for EKS encryption (optional)"
  type        = string
  default     = ""
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver for persistent volumes"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_policy_arn" {
  description = "ARN of the EBS CSI driver IAM policy"
  type        = string
  default     = ""  # Will be created if not provided
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler IAM resources (Kubernetes resources managed by Helm)"
  type        = bool
  default     = true
}

variable "cluster_autoscaler_policy_arn" {
  description = "ARN of the cluster autoscaler IAM policy (optional, will be created if not provided)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "helicone"
    ManagedBy   = "terraform"
  }
}

# EKS Add-on Versions
variable "vpc_cni_version" {
  description = "Version of the VPC CNI add-on"
  type        = string
  default     = "v1.18.1-eksbuild.1"  # Update based on your EKS version
}

variable "coredns_version" {
  description = "Version of the CoreDNS add-on"
  type        = string
  default     = "v1.11.1-eksbuild.9"  # Update based on your EKS version
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy add-on"
  type        = string
  default     = "v1.29.3-eksbuild.2"  # Update based on your EKS version
}

variable "ebs_csi_driver_version" {
  description = "Version of the EBS CSI driver add-on"
  type        = string
  default     = "v1.30.0-eksbuild.1"  # Latest stable version
}

#################################################################################
# AWS Auth ConfigMap Configuration
#################################################################################

variable "manage_aws_auth" {
  description = "Whether to manage the aws-auth ConfigMap via Terraform"
  type        = bool
  default     = true
}

variable "additional_aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "additional_aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "enable_ingress_nginx_lb_lookup" {
  description = "Enable lookup of the ingress-nginx load balancer for zone ID output"
  type        = bool
  default     = false
}

# EKS Pod Identity Agent Configuration
variable "enable_pod_identity_agent" {
  description = "Enable EKS Pod Identity Agent addon"
  type        = bool
  default     = true
}

variable "pod_identity_agent_version" {
  description = "Version of the EKS Pod Identity Agent addon"
  type        = string
  default     = "v1.0.0-eksbuild.1"
}

# AWS Load Balancer Controller Configuration
variable "enable_alb_controller" {
  description = "Enable AWS Load Balancer Controller for managing ALBs and NLBs"
  type        = bool
  default     = false
}

variable "alb_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy (optional, will be created if not provided)"
  type        = string
  default     = ""
}

variable "alb_controller_namespace" {
  description = "Namespace for the ALB controller"
  type        = string
  default     = "default"
}

#################################################################################
# NGINX Ingress Controller Configuration
#################################################################################

variable "enable_nginx_ingress_controller" {
  description = "Enable NGINX Ingress Controller with Pod Identity"
  type        = bool
  default     = true
}

variable "nginx_ingress_controller_namespace" {
  description = "Namespace for NGINX Ingress Controller"
  type        = string
  default     = "helicone-infrastructure"
}

#################################################################################
# AI Gateway Configuration
#################################################################################

variable "valkey_cache_arns" {
  description = "Map of region to Valkey serverless cache ARN"
  type        = map(string)
  default     = {
    us-west-2 = ""
    us-east-1 = ""
  }
}

variable "s3_bucket_arns" {
  description = "Map of region to S3 bucket ARN for request-response storage"
  type        = map(string)
  default     = {
    us-west-2 = "arn:aws:s3:::request-response-storage-us-west-2"
    us-east-1 = "arn:aws:s3:::request-response-storage-us-east-1"
  }
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
