# Helicone Helm Chart

This project is licensed under Apache 2.0 with The Commons Clause.

## Overview

This repository includes Helm charts for complete Helicone stack on Kubernetes. The following charts
are included:

<!-- TODO Update to include the up to date helm charts that are created -->

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

### Helm Installation

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

<!-- TODO Explain how to set up ingress -->

## Infrastructure Deployment with Terraform

### Module Structure

- **`terraform/eks/`** - Core EKS cluster infrastructure (cluster, nodes, networking)
- **`terraform/route53-acm/`** - SSL certificates and Route53 DNS management
- **`terraform/cloudflare/`** - External DNS management via Cloudflare (optional)
- **`terraform/s3/`** - S3 storage buckets (optional)
<!-- TODO Add the rest of the module structures -->

### Deployment Order

Deploy the modules in this specific order due to dependencies:

**Deploy EKS Infrastructure** (required)
   <!-- TODO Explain how the modules for different regions work -->

   ```bash
   cd terraform/eks
   terraform init
   terraform validate
   terraform apply
   ```

Note: We also allow deploying the Cloudflare module as a DNS provider instead of Route53

<!-- TODO Explain gitops approach -->
