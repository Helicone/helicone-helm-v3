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

### Autoscaling Configuration

The Helicone Helm chart supports both Cluster Autoscaling (node-level) and Horizontal Pod Autoscaling (HPA) for automatic scaling based on workload demands.

#### Prerequisites for Autoscaling

1. **Metrics Server** (required for HPA):

   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

2. **IAM OIDC Provider** (required for cluster autoscaling):

   ```bash
   eksctl utils associate-iam-oidc-provider \
     --region us-east-2 \
     --cluster helicone \
     --approve
   ```

#### Setting up Cluster Autoscaling

Cluster Autoscaler automatically adjusts the number of nodes in your cluster based on pod requirements.

1. **Create IAM Policy** for Cluster Autoscaler:

   Create a file `cluster-autoscaler-policy.json`:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "autoscaling:DescribeAutoScalingGroups",
           "autoscaling:DescribeAutoScalingInstances",
           "autoscaling:DescribeLaunchConfigurations",
           "autoscaling:DescribeScalingActivities",
           "autoscaling:DescribeTags",
           "ec2:DescribeImages",
           "ec2:DescribeInstanceTypes",
           "ec2:DescribeLaunchTemplateVersions",
           "ec2:GetInstanceTypesFromInstanceRequirements"
         ],
         "Resource": "*"
       },
       {
         "Effect": "Allow",
         "Action": [
           "autoscaling:SetDesiredCapacity",
           "autoscaling:TerminateInstanceInAutoScalingGroup"
         ],
         "Resource": "*",
         "Condition": {
           "StringEquals": {
             "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/helicone": "owned",
             "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled": "true"
           }
         }
       }
     ]
   }
   ```

   Apply the policy:

   ```bash
   aws iam create-policy \
     --policy-name EKSClusterAutoscalerPolicy \
     --policy-document file://cluster-autoscaler-policy.json
   ```

2. **Create Service Account** with IAM role:

   ```bash
   eksctl create iamserviceaccount \
     --cluster=helicone \
     --namespace=kube-system \
     --name=cluster-autoscaler \
     --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/EKSClusterAutoscalerPolicy \
     --override-existing-serviceaccounts \
     --approve
   ```

3. **Tag Auto Scaling Groups**:

   ```bash
   # Get node group names
   NODE_GROUPS=$(aws eks list-nodegroups --cluster-name helicone --query 'nodegroups[]' --output text)
   
   # Tag each ASG
   for ng in $NODE_GROUPS; do
     ASG_NAME=$(aws eks describe-nodegroup --cluster-name helicone --nodegroup-name $ng \
       --query 'nodegroup.resources.autoScalingGroups[0].name' --output text)
     
     aws autoscaling create-or-update-tags \
       --tags "ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=false" \
              "ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/helicone,Value=owned,PropagateAtLaunch=false"
   done
   ```

4. **Configure in values.yaml**:

   ```yaml
   clusterAutoscaler:
     enabled: true
     image:
       tag: "v1.29.2"  # Use version compatible with your K8s version
     clusterName: "helicone"
     serviceAccount:
       roleArn: "arn:aws:iam::<AWS_ACCOUNT_ID>:role/eksctl-helicone-addon-iamserviceaccount-ku-Role1-XXXXX"
   ```

#### Horizontal Pod Autoscaling (HPA)

HPA automatically scales the number of pods based on CPU/memory utilization.

The Helicone chart includes HPA configuration for web and jawn services by default:

```yaml
# In values.yaml
helicone:
  web:
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
      targetCPUUtilizationPercentage: 80
      targetMemoryUtilizationPercentage: 80
  
  jawn:
    autoscaling:
      enabled: true
      minReplicas: 1
      maxReplicas: 10
      targetCPUUtilizationPercentage: 80
      targetMemoryUtilizationPercentage: 80
```

#### Vertical Pod Autoscaling (VPA) - Optional

VPA automatically adjusts pod resource requests and limits based on usage patterns.

1. **Install VPA**:

   ```bash
   git clone https://github.com/kubernetes/autoscaler.git
   cd autoscaler/vertical-pod-autoscaler/
   ./hack/vpa-install.sh
   ```

2. **Enable in values.yaml**:

   ```yaml
   helicone:
     web:
       verticalPodAutoscaler:
         enabled: true
         updateMode: "Off"  # Options: "Off", "Initial", "Recreate", "Auto"
   ```

#### Automated Setup Script

For convenience, use the provided setup script:

```bash
./setup-autoscaling.sh
```

This script will:

- Check prerequisites
- Install Metrics Server
- Create IAM policies and service accounts
- Tag Auto Scaling Groups
- Update your values.yaml automatically

#### Verifying Autoscaling

1. **Check HPA status**:

   ```bash
   kubectl get hpa -n default
   ```

2. **Monitor Cluster Autoscaler logs**:

   ```bash
   kubectl logs -f deployment/cluster-autoscaler -n kube-system
   ```

3. **Test autoscaling**:

   ```bash
   # Create a load test to trigger HPA
   kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://helicone-web:3000; done"
   ```

4. **Monitor node scaling**:

   ```bash
   kubectl get nodes --watch
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
