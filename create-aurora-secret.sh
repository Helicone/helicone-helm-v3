#!/bin/bash

# Script to create Kubernetes secret with Aurora PostgreSQL credentials
# This pulls the password from AWS Secrets Manager and creates a K8s secret

echo "🔐 Creating Kubernetes secret for Aurora PostgreSQL credentials..."

# Get the password from AWS Secrets Manager
AURORA_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id helicone-aurora-cluster-master-password \
  --region us-west-2 \
  --query 'SecretString' \
  --output text | jq -r '.password')

if [ $? -ne 0 ] || [ -z "$AURORA_PASSWORD" ]; then
  echo "❌ Failed to retrieve Aurora password from AWS Secrets Manager"
  exit 1
fi

echo "✅ Retrieved Aurora password from AWS Secrets Manager"

# Create or update the Kubernetes secret
kubectl create secret generic aurora-postgres-credentials \
  --from-literal=password="$AURORA_PASSWORD" \
  --from-literal=host="helicone-aurora-cluster.cluster-cr0pbknv3xbp.us-west-2.rds.amazonaws.com" \
  --from-literal=port="5432" \
  --from-literal=database="helicone" \
  --from-literal=username="helicone_admin" \
  --dry-run=client -o yaml | kubectl apply -f -

if [ $? -eq 0 ]; then
  echo "✅ Kubernetes secret 'aurora-postgres-credentials' created/updated successfully"
else
  echo "❌ Failed to create Kubernetes secret"
  exit 1
fi

echo "🎉 Aurora credentials are now available in Kubernetes!" 