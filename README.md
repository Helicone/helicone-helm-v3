# Helicone Helm Chart

This project is licensed under Apache 2.0 with The Commons Clause.

## Overview

This repository includes Helm charts for complete Helicone stack on Kubernetes. The following charts
are included:

- **helicone-core** - Main application components (web, jawn, worker, AI gateway, etc.)
- **helicone-ai-gateway** - Helicone's AI Gateway
- **helicone-infrastructure** - Infrastructure services (eBPF)
- **helicone-monitoring** - Monitoring stack (Grafana, Prometheus)
- **helicone-argocd** - ArgoCD for GitOps workflows

All Helicone services needed to get up and running are in the `helicone-core` Helm chart.

### Prerequisites

1. Install **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)** - For Kubernetes
   operations
2. Install **[Helm](https://helm.sh/docs/intro/install/)** - For chart deployment
3. Set up a cluster. To assist with the creation of this cluster, we have
   **[Terraform](https://developer.hashicorp.com/terraform/install)** resources for EKS, Route53,
   and Cloudflare.
4. Copy all values.example.yaml files to values.yaml for each of the charts in `charts/` and
   customize as needed for your configuration.

## Deploy Helm Charts

Assuming you have a cluster ready, follow one of these options to deploy the Helicone stack.

### Option 1: Using Helm Compose (Recommended)

You can now deploy all Helicone components with a single command using the provided
`helm-compose.yaml` configuration:

```bash
helm compose up
```

To tear down all components:

```bash
helm compose down
```

You can further specify the charts you with to deploy by altering the releases section of
`helm-compose.yaml`.

### Option 2: Manual Helm Installation

Alternatively, you can install components individually:

1. Install necessary helm dependencies. For example, for helicone-core:

   ```bash
   cd helicone-core && helm dependency build
   ```

2. Use `values.example.yaml` as a starting point, and copy into `values.yaml`, then change the
   secrets accordingly.

3. Install/upgrade each Helm chart individually (do so within each respective directory):

   ```bash
   # Install core Helicone application components
   helm upgrade --install helicone-core ./helicone-core -f values.yaml

   # Install AI Gateway component
   helm upgrade --install helicone-ai-gateway ./helicone-ai-gateway -f values.yaml

   # Install infrastructure services (autoscaling, loki, nginx ingress controller)
   helm upgrade --install helicone-infrastructure ./helicone-infrastructure -f values.yaml

   # Install monitoring stack (Grafana, Prometheus)
   helm upgrade --install helicone-monitoring ./helicone-monitoring -f values.yaml

   # Install ArgoCD for GitOps workflows
   helm upgrade --install helicone-argocd ./helicone-argocd -f values.yaml
   ```

4. Verify the deployment:

   ```bash
   kubectl get pods
   ```

## Exposing Helicone Services with a Load Balancer (Ingress)

To make the Helicone web and jawn services accessible via your custom domains (e.g.,
`heliconetest.com`), you need to set up an Ingress controller with a LoadBalancer in your Kubernetes
cluster. This is required for routing external traffic to your services using the domains configured
in your `values.yaml`.

### 1. Install the NGINX Ingress Controller with a LoadBalancer

You only need to do this once per cluster. Run the following commands:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.service.type=LoadBalancer
```

This will install the NGINX Ingress controller and expose it via a cloud LoadBalancer. The Ingress
controller is responsible for routing external HTTP/HTTPS traffic to your Helicone services based on
the Ingress resources defined in your Helm chart.

### 2. Get the LoadBalancer's External IP or Hostname

After a few minutes, retrieve the external IP or hostname assigned to the Ingress controller:

```bash
kubectl get svc -n default
```

### 3. Configure DNS

Update your DNS provider (e.g., Route53, Cloudflare) to point your domain (e.g., `heliconetest.com`)
to the LoadBalancer's external IP or hostname. This ensures that traffic to your domain is routed to
your Kubernetes cluster.

- For an IP address, create an A record.
- For a hostname, create a CNAME record.

### 4. TLS/HTTPS (Optional but Recommended)

If you want to enable HTTPS, you can use [cert-manager](https://cert-manager.io/) to automatically
provision TLS certificates. Install cert-manager with:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

Make sure your Ingress resources reference the correct TLS secret and cluster issuer as shown in
your `values.yaml`.

### 5. Deploy Helicone Helm Charts

Once the Ingress controller is set up and DNS is configured, deploy your Helicone Helm charts as
described below. By default, ingress is set up for web and jawn, which is thereafter accessible at
the domains you configured.

## Gateway API Testing

This repository includes comprehensive KUTTL tests for validating the Gateway API implementation that replaces traditional Ingress resources. The Gateway API provides better separation of concerns and more powerful traffic management capabilities.

### Running Tests

The tests validate AWS Gateway Controller deployment, GatewayClass resources, ALB/NLB Gateway functionality, and cross-namespace routing.

#### Prerequisites

```bash
# Install KUTTL
brew tap kudobuilder/tap
brew install kuttl-cli

# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```

#### Run Tests

```bash
# Run all Gateway API tests
cd tests/
kubectl kuttl test

# Run specific test suites
kubectl kuttl test --test e2e/gateway-api/gateway-controller
kubectl kuttl test --test e2e/gateway-api/cross-namespace

# Run with verbose output
kubectl kuttl test --verbose
```

#### Automated Testing

Tests automatically run on pull requests via GitHub Actions. Results are posted as PR comments with pass/fail status for each test suite.

For more details, see the [test documentation](tests/README.md).

## Infrastructure Deployment with Terraform

### Module Structure

- **`terraform/eks/`** - Core EKS cluster infrastructure (cluster, nodes, networking)
- **`terraform/route53-acm/`** - SSL certificates and Route53 DNS management
- **`terraform/cloudflare/`** - External DNS management via Cloudflare (optional)
- **`terraform/s3/`** - S3 storage buckets (optional)
- **`terraform/aurora/`** - Aurora PostgreSQL database (optional)

### Deployment Order

Deploy the modules in this specific order due to dependencies:

1. **Deploy EKS Infrastructure** (required)

   ```bash
   cd terraform/eks
   terraform init
   terraform validate
   terraform apply
   ```

2. **Deploy Route53/ACM Module** (required for SSL and DNS)

   ```bash
   cd terraform/route53-acm
   terraform init
   terraform validate
   terraform apply
   ```

Note: We also allow deploying the Cloudflare module as a DNS provider instead of Route53

## Configuring S3 (Optional)

### Terraform Setup with Service Account Access (Recommended)

For secure S3 access using IAM roles for service accounts (IRSA):

1. Navigate to `terraform/s3` and configure your variables:

   ```bash
   cd terraform/s3
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set:

   ```hcl
   enable_service_account_access = true
   eks_oidc_provider = "oidc.eks.us-west-2.amazonaws.com/id/YOUR_CLUSTER_OIDC_ID"
   kubernetes_namespace = "helicone"
   ```

3. Get your EKS OIDC provider URL:

   ```bash
   aws eks describe-cluster --name YOUR_CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed 's|https://||'
   ```

4. Apply the Terraform configuration:

   ```bash
   terraform validate && terraform apply
   ```

5. Configure the Helm chart in `charts/helicone-core/values.yaml`:

   ```yaml
   helicone:
     minio:
       enabled: false # Disable MinIO when using real S3
     s3:
       serviceAccount:
         enabled: true
         roleArn: "arn:aws:iam::123456789012:role/helm-request-response-storage-service-account-role" # From terraform output
       bucketName: "helm-request-response-storage"
       endpoint: "https://s3.amazonaws.com"
   ```

### Alternative: Access Key Setup

If minio is enabled, then it will take the place of S3. Minio is a storage solution similar to AWS
S3, which can be used for local testing. If minio is disabled by setting the enabled flag under that
service to false, then the following parameters are used to configure the bucket:

- s3BucketName
- s3Endpoint
- s3AccessKey (secret)
- s3SecretKey (secret)

### CORS Configuration

Make sure to enable the following CORS policy on the S3 bucket, such that the web service can fetch
URL's from the bucket. To do so in AWS, in the bucket settings, set the following under Permissions
-> Cross-origin resource sharing (CORS):

```yaml
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET"],
    "AllowedOrigins": ["https://heliconetest.com"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000,
  },
]
```

## Aurora Setup via Terraform

AWS Aurora is supported as an alternative to a vanilla postgres deployment. To set up an Aurora
postgresql database using Terraform, follow these steps:

1. Navigate to the terraform/aurora directory:

   ```bash
   cd terraform/aurora
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Validate the Terraform configuration:

   ```bash
   terraform validate
   ```

4. Apply the Terraform configuration to create the Aurora cluster:

   ```bash
   terraform apply
   ```

After the aurora resource is created, make sure to set enabled to false for postgresql. This will
allow the aurora cluster to be used in its place.

## Additional Services

### Grafana

Grafana is deployed as part of the **helicone-monitoring** component and provides observability
dashboards for monitoring your Helicone deployment. It works alongside Prometheus to collect and
visualize metrics from all your services.

#### Accessing Grafana UI

1. Port-forward to access the Grafana server:

   ```bash
   kubectl port-forward svc/grafana -n monitoring 3000:80
   ```

2. Access the Grafana UI at: `http://localhost:3000`

3. Get the admin password (if using default configuration):

   ```bash
   kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
   ```

4. Login with username `admin` and the password retrieved above.

5. Pre-configured dashboards for Helicone services should be available under the Dashboards section.

### ArgoCD

ArgoCD is deployed as part of the **helicone-argocd** component and provides GitOps capabilities for
continuous deployment. It monitors your Git repositories and automatically synchronizes your
Kubernetes cluster state with the desired state defined in your Git repos.

#### Accessing ArgoCD UI

1. Port-forward to access the ArgoCD server:

   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

2. Access the ArgoCD UI at: `https://localhost:8080`

3. Get the initial admin password:

   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

4. Login with username `admin` and the password retrieved above.
