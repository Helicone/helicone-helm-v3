#!/bin/bash

# Script to install Grafana observability stack for Kubernetes
# This installs kube-prometheus-stack which includes Prometheus, Grafana, and AlertManager

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus-stack"
VALUES_FILE="kube-prometheus-stack-values.yaml"

echo -e "${GREEN}=== Grafana Observability Stack Installation ===${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists kubectl; then
    echo -e "${RED}Error: kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

if ! command_exists helm; then
    echo -e "${RED}Error: helm is not installed. Please install helm first.${NC}"
    exit 1
fi

# Check if connected to a cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Not connected to a Kubernetes cluster. Please configure kubectl.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites satisfied${NC}"
echo ""

# Get current cluster context
CURRENT_CONTEXT=$(kubectl config current-context)
echo -e "${YELLOW}Current Kubernetes context: ${GREEN}$CURRENT_CONTEXT${NC}"
read -p "Do you want to proceed with this cluster? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

# Create namespace
echo -e "\n${YELLOW}Creating namespace '$NAMESPACE'...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Prometheus community Helm repository
echo -e "\n${YELLOW}Adding Prometheus community Helm repository...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Check if release already exists
if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo -e "\n${YELLOW}Release '$RELEASE_NAME' already exists in namespace '$NAMESPACE'.${NC}"
    read -p "Do you want to upgrade the existing release? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
    HELM_COMMAND="upgrade"
else
    HELM_COMMAND="install"
fi

# Install/Upgrade kube-prometheus-stack
echo -e "\n${YELLOW}Installing/Upgrading kube-prometheus-stack...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

# Check if values file exists
if [ ! -f "$VALUES_FILE" ]; then
    echo -e "${RED}Error: Values file '$VALUES_FILE' not found in current directory.${NC}"
    echo -e "${YELLOW}Make sure you're running this script from the grafana-observability directory.${NC}"
    exit 1
fi

helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
    --namespace $NAMESPACE \
    --values $VALUES_FILE \
    --wait \
    --timeout 10m

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Grafana observability stack installed/upgraded successfully!${NC}"
else
    echo -e "\n${RED}✗ Installation/upgrade failed. Please check the error messages above.${NC}"
    exit 1
fi

# Wait for pods to be ready
echo -e "\n${YELLOW}Waiting for core components to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n $NAMESPACE --timeout=300s || true
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n $NAMESPACE --timeout=300s || true
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alertmanager -n $NAMESPACE --timeout=300s || true

# Get service information
echo -e "\n${GREEN}=== Service Information ===${NC}"
echo -e "\n${YELLOW}Grafana:${NC}"
GRAFANA_SERVICE=$(kubectl get svc -n $NAMESPACE | grep grafana | grep -v alertmanager | head -1 | awk '{print $1}')
if [ ! -z "$GRAFANA_SERVICE" ]; then
    kubectl get svc $GRAFANA_SERVICE -n $NAMESPACE
    echo -e "${YELLOW}Default credentials: admin / admin${NC}"
fi

echo -e "\n${YELLOW}Prometheus:${NC}"
PROMETHEUS_SERVICE=$(kubectl get svc -n $NAMESPACE | grep prometheus | grep -v operator | grep -v alertmanager | head -1 | awk '{print $1}')
if [ ! -z "$PROMETHEUS_SERVICE" ]; then
    kubectl get svc $PROMETHEUS_SERVICE -n $NAMESPACE
fi

echo -e "\n${YELLOW}AlertManager:${NC}"
ALERTMANAGER_SERVICE=$(kubectl get svc -n $NAMESPACE | grep alertmanager | head -1 | awk '{print $1}')
if [ ! -z "$ALERTMANAGER_SERVICE" ]; then
    kubectl get svc $ALERTMANAGER_SERVICE -n $NAMESPACE
fi

# Port forwarding instructions
echo -e "\n${GREEN}=== Access Instructions ===${NC}"
echo -e "\n${YELLOW}To access Grafana locally:${NC}"
echo "kubectl port-forward -n $NAMESPACE svc/$GRAFANA_SERVICE 3000:80"
echo "Then open http://localhost:3000 in your browser"
echo ""
echo -e "${YELLOW}To access Prometheus locally:${NC}"
echo "kubectl port-forward -n $NAMESPACE svc/$PROMETHEUS_SERVICE 9090:9090"
echo "Then open http://localhost:9090 in your browser"
echo ""
echo -e "${YELLOW}To access AlertManager locally:${NC}"
echo "kubectl port-forward -n $NAMESPACE svc/$ALERTMANAGER_SERVICE 9093:9093"
echo "Then open http://localhost:9093 in your browser"

echo -e "\n${GREEN}✓ Installation complete!${NC}" 