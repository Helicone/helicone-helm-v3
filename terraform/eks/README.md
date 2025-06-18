# EKS Cluster Terraform Configuration

This Terraform configuration creates a production-ready Amazon EKS cluster with all necessary
components for running the Helicone application.

## Architecture Overview

This configuration creates:

- **EKS Cluster** (v1.29) in us-east-2
- **VPC** with public and private subnets across 3 availability zones
- **Node Group** with t3.medium instances (auto-scaling 1-3 nodes)
- **EKS Add-ons**:
  - VPC CNI for pod networking
  - CoreDNS for cluster DNS
  - kube-proxy for service networking
  - EBS CSI Driver for persistent volume support
- **Cluster Autoscaler** for automatic node scaling
- **IAM Roles and Policies** for secure operation

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (version 1.0+)
3. kubectl installed for cluster management
4. helm installed for application deployment

## Quick Start

1. Navigate to the EKS terraform directory:

   ```bash
   cd terraform/k8s
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review the planned changes:

   ```bash
   terraform plan
   ```

4. Apply the configuration:

   ```bash
   terraform apply
   ```

5. Configure kubectl:

   ```bash
   aws eks update-kubeconfig --region us-east-2 --name helicone
   ```

6. Verify cluster access:

   ```bash
   kubectl get nodes
   ```

## Configuration

### Key Variables

| Variable              | Description                    | Default         |
| --------------------- | ------------------------------ | --------------- |
| `cluster_name`        | Name of the EKS cluster        | `helicone`      |
| `region`              | AWS region                     | `us-east-2`     |
| `kubernetes_version`  | EKS version                    | `1.29`          |
| `node_instance_types` | EC2 instance types for nodes   | `["t3.medium"]` |
| `node_desired_size`   | Desired number of nodes        | `2`             |
| `node_min_size`       | Minimum nodes for auto-scaling | `1`             |
| `node_max_size`       | Maximum nodes for auto-scaling | `3`             |

### Advanced Configuration

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
region = "us-west-2"
cluster_name = "helicone-prod"
kubernetes_version = "1.30"

node_instance_types = ["t3.large"]
node_desired_size = 3
node_max_size = 5

tags = {
  Environment = "production"
  Team        = "platform"
  CostCenter  = "engineering"
}
```

### Related Modules

This EKS module provides the core Kubernetes infrastructure. For complete application setup:

**DNS and SSL Certificates:**

- See the [Route53/ACM module](../route53-acm/README.md) for managing SSL certificates and Route53
  DNS records
- The route53-acm module reads the EKS load balancer hostname via Terraform remote state

**External DNS Management:**

- See the [Cloudflare module](../cloudflare/README.md) for managing external DNS records
- The Cloudflare module reads certificate validation options from the route53-acm module

**Deployment Order:**

1. Deploy this EKS module first
2. Deploy the route53-acm module for SSL and internal DNS
3. Deploy the Cloudflare module for external DNS (optional)

## Features

### High Availability

- Multi-AZ deployment across 3 availability zones
- NAT Gateways in each AZ for redundancy
- Auto-scaling enabled for worker nodes

### Security

- Private subnets for worker nodes
- Encryption at rest for EKS secrets using AWS KMS
- IAM roles for service accounts (IRSA) enabled
- Security groups configured for least privilege

### Storage

- EBS CSI Driver installed and configured
- Support for dynamic persistent volume provisioning
- GP3 storage class available by default

### Autoscaling

- **Cluster Autoscaler**: Automatically adjusts the number of nodes based on pod requirements
- **Node Group Autoscaling**: Configured with min/max node limits
- Pre-configured with necessary IAM permissions and Kubernetes RBAC

### Monitoring & Logging

- CloudWatch logging enabled for:
  - API server
  - Audit logs
  - Authenticator
  - Controller manager
  - Scheduler

## Post-Deployment Steps

### 1. Install Metrics Server (Required for HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 2. Deploy Cluster Autoscaler

The IAM roles and service accounts are already created. Deploy the autoscaler:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

Edit the deployment to add your cluster name:

```bash
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```

Add the following to the command:

```yaml
- --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/helicone
- --balance-similar-node-groups
- --skip-nodes-with-system-pods=false
```

### 3. Install Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx ingress-nginx/ingress-nginx \
  --namespace nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

### 4. Install Cert-Manager (for HTTPS)

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

## Outputs

After deployment, Terraform will output:

- `cluster_endpoint` - EKS API server endpoint
- `cluster_name` - Name of the created cluster
- `kubectl_config` - Command to configure kubectl
- `vpc_id` - VPC ID for reference
- `node_group_role_arn` - IAM role for worker nodes
- `cluster_autoscaler_role_arn` - IAM role for cluster autoscaler

## Troubleshooting

### Nodes not joining cluster

1. Check node group status:

   ```bash
   aws eks describe-nodegroup --cluster-name helicone --nodegroup-name helicone-node-group
   ```

2. Verify IAM roles are correctly attached

3. Check security group rules allow communication

### Persistent volumes not working

1. Verify EBS CSI driver is running:

   ```bash
   kubectl get pods -n kube-system | grep ebs-csi
   ```

2. Check IAM permissions for the driver

### Cluster autoscaler not scaling

1. Check autoscaler logs:

   ```bash
   kubectl logs -n kube-system deployment/cluster-autoscaler
   ```

2. Verify ASG tags are correctly set

## Maintenance

### Updating EKS Version

1. Update the `kubernetes_version` variable
2. Run `terraform plan` to see changes
3. Apply changes: `terraform apply`
4. Update node groups after control plane update

### Scaling Nodes

To change node capacity:

```bash
terraform apply -var="node_desired_size=4" -var="node_max_size=6"
```

## Cost Optimization

- Use spot instances for non-critical workloads
- Enable cluster autoscaler to scale down during off-peak
- Consider using Graviton-based instances (t4g.medium)
- Review and adjust node disk sizes based on actual usage

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete the entire EKS cluster and all resources within it. Ensure you have
backed up any important data.
