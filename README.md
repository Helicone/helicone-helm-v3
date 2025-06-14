# Helicone Helm Chart

This project is licensed under Apache 2.0 with The Commons Clause.

## Overview

This Helm chart deploys the complete Helicone stack on Kubernetes. Terraform creates AWS S3, Aurora,
and EKS resources to run the Helicone project on.

## AWS Setup Guide

### Prerequisites

1. Install **[AWS CLI](https://aws.amazon.com/cli/)** - Install and configure with appropriate
   permissions
2. Install **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)** - For Kubernetes
   operations
3. Install **[Helm](https://helm.sh/docs/intro/install/)** - For chart deployment
4. Install **[Terraform](https://developer.hashicorp.com/terraform/install)** - For infrastructure
   as code deployment
5. Copy all values.example.yaml files to values.yaml for each of the charts in `charts/` and
   customize as needed for your configuration.

## Cluster Creation on EKS with Terraform

1. Set up [Terraform](https://developer.hashicorp.com/terraform/install)
2. Go to terraform/eks, then `terraform init`, followed by `terrform validate` followed by
   `terraform apply`

## Deploy Helm Charts

### Option 1: Using Helm Compose (Recommended)

You can now deploy all Helicone components with a single command using the provided
`helm-compose.yaml` configuration:

```bash
helm compose up
```

This will deploy the complete Helicone stack including:

- **helicone-core** - Main application components (web, jawn, worker, etc.)
- **helicone-infrastructure** - Infrastructure services (PostgreSQL, Redis, ClickHouse, etc.)
- **helicone-monitoring** - Monitoring stack (Grafana, Prometheus)
- **helicone-argocd** - ArgoCD for GitOps workflows

To tear down all components:

```bash
helm compose down
```

### Option 2: Manual Helm Installation

Alternatively, you can install components individually:

### Option 1: Using Helm Compose (Recommended)

You can now deploy all Helicone components with a single command using the provided
`helm-compose.yaml` configuration:

```bash
helm compose up
```

This will deploy the complete Helicone stack including:

- **helicone-core** - Main application components (web, jawn, worker, etc.)
- **helicone-infrastructure** - Infrastructure services (PostgreSQL, Redis, ClickHouse, etc.)
- **helicone-monitoring** - Monitoring stack (Grafana, Prometheus)
- **helicone-argocd** - ArgoCD for GitOps workflows

To tear down all components:

```bash
helm compose down
```

### Option 2: Manual Helm Installation

Alternatively, you can install components individually:

1. Install necessary helm dependencies:

   ```bash
   cd helicone && helm dependency build
   ```

2. Use `values.example.yaml` as a starting point, and copy into `values.yaml`

3. Copy `secrets.example.yaml` into `secrets.yaml`, and change the secrets according to your setup.

4. Install/upgrade each Helm chart individually:

   ```bash
   # Install core Helicone application components
   helm upgrade --install helicone-core ./helicone-core -f values.yaml

   # Install infrastructure services (autoscaling, [Beyla](https://grafana.com/docs/beyla/latest/))
   helm upgrade --install helicone-infrastructure ./helicone-infrastructure -f values.yaml

   # Install monitoring stack (Grafana, Prometheus)
   helm upgrade --install helicone-monitoring ./helicone-monitoring -f values.yaml

   # Install ArgoCD for GitOps workflows
   helm upgrade --install helicone-argocd ./helicone-argocd -f values.yaml
   ```

5. Verify the deployment:

   ```bash
   kubectl get pods
   ```

## Accessing Deployed Services

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

## Configuring S3 (Optional)

### Terraform Setup

Go to terraform/s3, then `terraform validate` followed by `terraform apply`

### Manual Setup

If minio is enabled, then it will take the place of S3. Minio is a storage solution similar to AWS
S3, which can be used for local testing. If minio is disabled by setting the enabled flag under that
service to false, then the following parameters are used to configure the bucket:

- s3BucketName
- s3Endpoint
- s3AccessKey (secret)
- s3SecretKey (secret)

Make sure to enable the following CORS policy on the S3 bucket, such that the web service can fetch
URL's from the bucket. To do so in AWS, in the bucket settings, set the following under Permissions
-> Cross-origin resource sharing (CORS):

```yaml
[
  {
    'AllowedHeaders': ['*'],
    'AllowedMethods': ['GET'],
    'AllowedOrigins': ['https://heliconetest.com'],
    'ExposeHeaders': ['ETag'],
    'MaxAgeSeconds': 3000,
  },
]
```

## Aurora Setup via Terraform

To set up an Aurora postgresql database using Terraform, follow these steps:

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
