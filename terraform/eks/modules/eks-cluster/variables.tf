# Module variables for EKS Cluster

variable "region" {
  description = "AWS region for the EKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
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
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10
}

variable "volume_size" {
  description = "EBS volume size for worker nodes in GB"
  type        = number
  default     = 50
}

variable "volume_type" {
  description = "EBS volume type for worker nodes"
  type        = string
  default     = "gp3"
}

variable "volume_iops" {
  description = "IOPS for EBS volumes (only for gp3)"
  type        = number
  default     = 3000
}

variable "volume_throughput" {
  description = "Throughput for EBS volumes in MiB/s (only for gp3)"
  type        = number
  default     = 125
}

variable "volume_encrypted" {
  description = "Enable EBS volume encryption"
  type        = bool
  default     = true
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# KMS Configuration
variable "kms_key_arn" {
  description = "ARN of the KMS key to use for EKS encryption. If empty, a new key will be created"
  type        = string
  default     = ""
}

variable "kms_key_deletion_window" {
  description = "The waiting period, specified in number of days for KMS key deletion"
  type        = number
  default     = 7
}

# EBS CSI Driver Configuration
variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver addon"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_policy_arn" {
  description = "ARN of an existing IAM policy for EBS CSI driver. If empty, a new policy will be created"
  type        = string
  default     = ""
}

# AWS Auth Configuration
variable "manage_aws_auth" {
  description = "Whether to manage the aws-auth configmap"
  type        = bool
  default     = false
}

variable "additional_aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "additional_aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "additional_aws_auth_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap"
  type        = list(string)
  default     = []
}

# AWS Load Balancer Controller Configuration
variable "enable_alb_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = false
}

variable "alb_controller_namespace" {
  description = "Namespace for AWS Load Balancer Controller"
  type        = string
  default     = "kube-system"
}

variable "alb_controller_policy_arn" {
  description = "ARN of an existing IAM policy for ALB controller. If empty, a new policy will be created"
  type        = string
  default     = ""
}

# EKS Pod Identity Agent Addon
variable "enable_pod_identity_agent" {
  description = "Enable EKS Pod Identity Agent addon"
  type        = bool
  default     = true
}

variable "pod_identity_agent_version" {
  description = "Version of the EKS Pod Identity Agent addon"
  type        = string
  default     = null
}

# Ingress Controller Configuration
variable "enable_nginx_ingress_controller" {
  description = "Enable NGINX Ingress Controller"
  type        = bool
  default     = false
}

variable "nginx_ingress_controller_namespace" {
  description = "Namespace for NGINX Ingress Controller"
  type        = string
  default     = "helicone-infrastructure"
}

variable "enable_ingress_nginx_lb_lookup" {
  description = "Enable lookup of NGINX ingress load balancer (set to true after ingress controller is deployed)"
  type        = bool
  default     = false
}

# EKS Addon Versions
variable "vpc_cni_version" {
  description = "Version of the VPC CNI addon"
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "Version of the CoreDNS addon"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy addon"
  type        = string
  default     = null
}

variable "ebs_csi_driver_version" {
  description = "Version of the EBS CSI driver addon"
  type        = string
  default     = null
}

# Cluster Autoscaler Configuration
variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_policy_arn" {
  description = "ARN of an existing IAM policy for cluster autoscaler. If empty, a new policy will be created"
  type        = string
  default     = ""
}

# AI Gateway Configuration
variable "valkey_cache_arn" {
  description = "ARN of the Valkey cache for AI Gateway"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for AI Gateway"
  type        = string
}

variable "ai_gateway_namespace" {
  description = "Namespace for AI Gateway"
  type        = string
  default     = "ai-gateway"
}