#!/bin/bash

# AWS EKS Autoscaling Setup Script
# This script helps configure autoscaling for your EKS cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_error "aws CLI is not installed"
        exit 1
    fi
    
    if ! command -v eksctl &> /dev/null; then
        print_error "eksctl is not installed"
        print_status "Install it with: brew install weaveworks/tap/eksctl (on macOS)"
        print_status "Or visit: https://eksctl.io/installation/"
        exit 1
    fi
    
    print_status "All prerequisites met!"
}

# Get cluster information
get_cluster_info() {
    print_status "Getting cluster information..."
    
    # Get current context
    CURRENT_CONTEXT=$(kubectl config current-context)
    print_status "Current context: $CURRENT_CONTEXT"
    
    # Extract cluster name and region from ARN (format: arn:aws:eks:region:account:cluster/name)
    if [[ $CURRENT_CONTEXT =~ arn:aws:eks:([^:]+):([^:]+):cluster/(.+) ]]; then
        REGION="${BASH_REMATCH[1]}"
        ACCOUNT_ID="${BASH_REMATCH[2]}"
        CLUSTER_NAME="${BASH_REMATCH[3]}"
    else
        # Fallback: try to extract just cluster name
        CLUSTER_NAME=$(echo $CURRENT_CONTEXT | sed 's/.*\///')
        
        # Get AWS account ID
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        
        # Get region from AWS CLI config as fallback
        REGION=$(aws configure get region)
        if [ -z "$REGION" ]; then
            REGION="us-west-2"
            print_warning "No region configured, defaulting to $REGION"
        fi
    fi
    
    print_status "Detected cluster name: $CLUSTER_NAME"
    print_status "AWS Account ID: $ACCOUNT_ID"
    print_status "Region: $REGION"
}

# Install Metrics Server
install_metrics_server() {
    print_status "Installing Metrics Server..."
    
    if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
        print_status "Metrics Server already installed"
    else
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
        print_status "Metrics Server installed"
    fi
    
    # Wait for metrics server to be ready
    print_status "Waiting for Metrics Server to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system
}

# Install VPA (optional)
install_vpa() {
    print_status "Installing Vertical Pod Autoscaler..."
    
    if kubectl get deployment vpa-recommender -n kube-system &> /dev/null; then
        print_status "VPA already installed"
    else
        # Clone VPA repository and install
        if [ ! -d "autoscaler" ]; then
            git clone https://github.com/kubernetes/autoscaler.git
        fi
        cd autoscaler/vertical-pod-autoscaler/
        ./hack/vpa-install.sh
        cd ../..
        print_status "VPA installed"
    fi
}

# Create IAM policy for cluster autoscaler
create_iam_policy() {
    print_status "Creating IAM policy for Cluster Autoscaler..."
    
    POLICY_NAME="ClusterAutoscalerPolicy"
    
    # Check if policy exists
    if aws iam get-policy --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME" &> /dev/null; then
        print_status "IAM policy already exists"
    else
        cat > cluster-autoscaler-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
        
        aws iam create-policy \
            --policy-name $POLICY_NAME \
            --policy-document file://cluster-autoscaler-policy.json
        
        rm cluster-autoscaler-policy.json
        print_status "IAM policy created"
    fi
}

# Create OIDC provider association
create_oidc_provider() {
    print_status "Checking IAM OIDC provider association..."
    
    # Check if OIDC provider exists
    OIDC_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.identity.oidc.issuer' --output text 2>/dev/null | sed 's|https://||')
    
    if [ -n "$OIDC_URL" ]; then
        # Check if the provider is already associated
        if aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?ends_with(Arn, '$OIDC_URL')]" --output text 2>/dev/null | grep -q "$OIDC_URL"; then
            print_status "IAM OIDC provider already exists"
        else
            print_status "Creating IAM OIDC provider association..."
            eksctl utils associate-iam-oidc-provider --region=$REGION --cluster=$CLUSTER_NAME --approve
            print_status "IAM OIDC provider created"
        fi
    else
        print_error "Could not retrieve OIDC issuer URL from cluster"
        exit 1
    fi
}

# Create service account for cluster autoscaler
create_service_account() {
    print_status "Creating service account for Cluster Autoscaler..."
    
    if kubectl get serviceaccount cluster-autoscaler -n kube-system &> /dev/null; then
        print_status "Service account already exists"
    else
        # Check if eksctl is available
        if ! command -v eksctl &> /dev/null; then
            print_error "eksctl is not installed. Please install eksctl first."
            print_status "You can install it with: brew install weaveworks/tap/eksctl"
            exit 1
        fi
        
        print_status "Using region: $REGION for eksctl commands"
        
        eksctl create iamserviceaccount \
            --cluster=$CLUSTER_NAME \
            --region=$REGION \
            --namespace=kube-system \
            --name=cluster-autoscaler \
            --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/ClusterAutoscalerPolicy \
            --override-existing-serviceaccounts \
            --approve
        
        print_status "Service account created"
    fi
}

# Tag Auto Scaling Groups
tag_asg() {
    print_status "Tagging Auto Scaling Groups..."
    
    # Get node groups
    NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --region $REGION --query 'nodegroups[]' --output text)
    
    for ng in $NODE_GROUPS; do
        print_status "Processing node group: $ng"
        
        # Get ASG name
        ASG_NAME=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $ng --region $REGION \
            --query 'nodegroup.resources.autoScalingGroups[0].name' --output text)
        
        if [ "$ASG_NAME" != "None" ] && [ "$ASG_NAME" != "" ]; then
            print_status "Tagging ASG: $ASG_NAME"
            
            aws autoscaling create-or-update-tags --region $REGION \
                --tags "ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=false" \
                       "ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/$CLUSTER_NAME,Value=owned,PropagateAtLaunch=false"
        fi
    done
}

# Update values.yaml with cluster-specific values
update_values() {
    print_status "Updating values.yaml with cluster-specific configuration..."
    
    # Get the service account role ARN
    SA_ROLE_ARN=$(kubectl get serviceaccount cluster-autoscaler -n kube-system -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}')
    
    # Update values.yaml
    sed -i.bak \
        -e "s/your-eks-cluster-name/$CLUSTER_NAME/g" \
        -e "s/YOUR-ACCOUNT-ID/$ACCOUNT_ID/g" \
        -e "s|arn:aws:iam::YOUR-ACCOUNT-ID:role/cluster-autoscaler-role|$SA_ROLE_ARN|g" \
        ../helicone/values.yaml
    
    print_status "values.yaml updated"
}

# Deploy Helm chart
deploy_helm() {
    print_status "Deploying Helm chart with autoscaling enabled..."
    
    helm upgrade --install helicone ../helicone \
        --namespace helicone \
        --create-namespace \
        --values ../helicone/values.yaml
    
    print_status "Helm deployment complete"
}

# Verify deployment
verify_deployment() {
    print_status "Verifying autoscaling deployment..."
    
    # Check HPA
    if kubectl get hpa -n helicone &> /dev/null; then
        print_status "✓ HPA deployed successfully"
        kubectl get hpa -n helicone
    else
        print_warning "HPA not found"
    fi
    
    # Check Cluster Autoscaler
    if kubectl get deployment cluster-autoscaler -n kube-system &> /dev/null; then
        print_status "✓ Cluster Autoscaler deployed successfully"
    else
        print_warning "Cluster Autoscaler not found"
    fi
    
    # Check VPA (if enabled)
    if kubectl get vpa -n helicone &> /dev/null; then
        print_status "✓ VPA deployed successfully"
        kubectl get vpa -n helicone
    fi
}

# Main function
main() {
    print_status "Starting EKS Autoscaling Setup..."
    
    check_prerequisites
    get_cluster_info
    install_metrics_server
    create_iam_policy
    create_oidc_provider
    create_service_account
    tag_asg
    update_values
    deploy_helm
    verify_deployment
    
    print_status "Setup complete! 🎉"
    print_status "Monitor your autoscaling with:"
    print_status "  kubectl get hpa -n helicone --watch"
    print_status "  kubectl logs -f deployment/cluster-autoscaler -n kube-system"
    print_status ""
    print_status "Check the EKS_AUTOSCALING_SETUP.md guide for monitoring and optimization tips."
}

# Run main function
main "$@" 