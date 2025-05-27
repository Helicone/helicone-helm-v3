# Helicone Helm Chart

This project is licensed under Apache 2.0 with The Commons Clause.

## Overview

This Helm chart deploys the complete Helicone stack on Kubernetes.

## AWS Setup Guide

### Prerequisites

1. **[AWS CLI](https://aws.amazon.com/cli/)** - Install and configure with appropriate permissions
2. **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)** - For Kubernetes operations
3. **[Helm](https://helm.sh/docs/intro/install/)** - For chart deployment
4. **[eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)** - For EKS cluster management

### AWS IAM Permissions

Create the necessary IAM policies for EKS and EBS volumes:

```bash
aws iam create-policy \
  --policy-name EKS-EBS-CSI-Driver-Policy \
  --policy-document file://eks-ebs-policy.json
```

### Creating an EKS Cluster

1. Create the EKS cluster:

   ```bash
   eksctl create cluster \
     --name helicone \
     --region us-east-2 \
     --version 1.32 \
     --node-type t3.medium \
     --nodes 2 \
     --nodes-min 1 \
     --nodes-max 3 \
     --managed
   ```

### Storage Configuration

Verify available storage classes:

```bash
kubectl get storageclass
```

### Install Cert-Manager & Ingress Controller

For production deployments with HTTPS, set up ingress:

1. Install cert-manager:

   ```bash
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   helm upgrade --install \
     cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --create-namespace \
     --set installCRDs=true
   kubectl apply -f example/prod_issuer.yaml
   ```

2. Install Ingress-NGINX:

   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   helm install nginx ingress-nginx/ingress-nginx \
     --namespace nginx \
     --create-namespace \
     --set rbac.create=true \
     --set controller.publishService.enabled=true
   ```

3. Get Load Balancer IP:

   ```bash
   kubectl get svc -n nginx nginx-ingress-nginx-controller
   ```

4. Configure your DNS to point to this Load Balancer IP.

## Deploy Helicone

1. Install necessary helm dependencies:

   ```bash
   cd helicone && helm dependency build
   ```

2. Use `values.example.yaml` as a starting point, and copy into `values.yaml`

3. Copy `secrets.example.yaml` into `secrets.yaml`, and change the secrets according to your setup.

4. Install/upgrade the Helm chart:

   ```bash
   helm upgrade --install helicone ./helicone -f values.yaml -f secrets.yaml
   ```

5. Verify the deployment:

   ```bash
   kubectl get pods
   ```

## Configuring S3 (Optional)

If minio is enabled, then it will take the place of S3. Minio is a storage solution similar to AWS S3, which can be used for local testing.
If minio is disabled by setting the enabled flag under that service to false, then the following parameters are used to configure the bucket:

- s3BucketName
- s3Endpoint
- s3AccessKey (secret)
- s3SecretKey (secret)

Make sure to enable the following CORS policy on the S3 bucket, such that the web service can fetch URL's from the bucket. To do so in AWS, in the bucket settings, set the following under Permissions -> Cross-origin resource sharing (CORS):

   ```yaml
   [
      {
         "AllowedHeaders": [
               "*"
         ],
         "AllowedMethods": [
               "GET"
         ],
         "AllowedOrigins": [
               "https://heliconetest.com"
         ],
         "ExposeHeaders": [
               "ETag"
         ],
         "MaxAgeSeconds": 3000
      }
   ]
   ```

## Scaling and Production Considerations

**Increase Node Count for Production:**

   ```bash
   eksctl scale nodegroup \
     --cluster helicone \
     --name <nodegroup-name> \
     --nodes 3
   ```

## Troubleshooting

### Common Issues

1. **PVC in Pending State:**

   - Check storage class configuration
   - Ensure EBS CSI driver policy is attached to node role
   - Verify node has capacity and is in the correct availability zone

2. **Pod Scheduling Issues:**

   - Check node capacity (`kubectl describe node`)
   - Increase node count if at capacity limit
   - Verify taints and tolerations

3. **Connection Issues:**
   - Check service endpoints (`kubectl get svc`)
   - Verify ingress configuration
   - Check secret configuration for database connections

Run diagnostic commands:

```bash
# Check pod statuses
kubectl get pods

# View pod logs
kubectl logs <pod-name>

# Describe a problematic pod
kubectl describe pod <pod-name>

# Port-forward to test services locally
kubectl port-forward svc/helicone-web 8080:3000
```

## Release Process

For chart maintainers:

1. Update `Chart.yaml` with the new version number.

2. Package the chart:

   ```bash
   helm package ./helicone
   ```

3. Push to ECR repository:

   ```bash
   aws ecr get-login-password --region us-east-2 | helm registry login \
     --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com

   helm push helicone-[VERSION].tgz oci://<AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/helicone-helm
   ```

## Clean Up

When done with testing or to delete the deployment:

1. Delete Helm release:

   ```bash
   helm uninstall helicone
   ```

2. Scale down node group to save costs:

   ```bash
   eksctl scale nodegroup \
     --cluster helicone \
     --name <nodegroup-name> \
     --nodes 0
   ```

3. Delete the EKS cluster when no longer needed:

   ```bash
   eksctl delete cluster --name helicone --region us-east-2
   ```
