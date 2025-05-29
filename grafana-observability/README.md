# Grafana Observability for Kubernetes

This directory contains the configuration and deployment scripts for setting up comprehensive observability for your Kubernetes cluster using Grafana, Prometheus, and related tools.

## 🚀 Quick Start

```bash
cd grafana-observability
./install-grafana-stack.sh
```

## 📊 What's Included

The `kube-prometheus-stack` Helm chart deploys a complete observability solution:

### Core Components

1. **Prometheus** - Time-series metrics database
   - Configured with 30-day retention
   - 50GB persistent storage
   - Auto-discovery of Kubernetes services

2. **Grafana** - Visualization and dashboards
   - Pre-configured dashboards for Kubernetes monitoring
   - Persistent storage for custom dashboards
   - Integration with Prometheus as default data source

3. **AlertManager** - Alert routing and management
   - Basic alert routing configuration
   - Persistent storage for silence rules

### Exporters and Metrics Collection

- **Node Exporter** - Hardware and OS metrics from nodes
- **Kube State Metrics** - Kubernetes object metrics
- **cAdvisor** (via Kubelet) - Container resource metrics
- **API Server metrics**
- **Controller Manager metrics**
- **Scheduler metrics**
- **etcd metrics**

### Pre-configured Dashboards

The stack includes 20+ pre-configured Grafana dashboards:

- **Cluster Overview** - High-level cluster metrics
- **Node Exporter Full** - Detailed node metrics
- **Kubernetes Pods** - Pod resource usage and status
- **Kubernetes Deployments** - Deployment health and rollout status
- **Kubernetes StatefulSets** - StatefulSet monitoring
- **Kubernetes Persistent Volumes** - Storage monitoring
- **Kubernetes Networking** - Network traffic and DNS
- **Kubernetes API Server** - API server performance
- **etcd** - etcd cluster health
- **CoreDNS** - DNS query performance

### Pre-configured Alerts

Basic alerting rules are included:

- **PodCrashLooping** - Pods that are restarting frequently
- **HighMemoryUsage** - Nodes with >90% memory usage
- **HighCPUUsage** - Nodes with >80% CPU usage
- **KubeAPIDown** - Kubernetes API unreachable
- **KubeNodeNotReady** - Nodes in NotReady state

## 📋 Prerequisites

- Kubernetes cluster (1.19+)
- `kubectl` configured to access your cluster
- `helm` 3.x installed
- At least 4GB of free memory in your cluster
- Storage provisioner for persistent volumes

## 🛠️ Installation

### Automated Installation

Use the provided script for the easiest installation:

```bash
./install-grafana-stack.sh
```

The script will:
- Check prerequisites
- Create the `monitoring` namespace
- Add the Prometheus community Helm repository
- Install/upgrade the kube-prometheus-stack
- Wait for all pods to be ready
- Display access instructions

### Manual Installation

If you prefer to install manually:

```bash
# Create namespace
kubectl create namespace monitoring

# Add Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install the stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values kube-prometheus-stack-values.yaml
```

## 🔧 Configuration

### Customizing the Installation

Edit `kube-prometheus-stack-values.yaml` to customize:

- **Resource limits** - Adjust CPU/memory for components
- **Storage sizes** - Modify persistent volume sizes
- **Retention periods** - Change metric retention duration
- **Service types** - Switch between LoadBalancer/NodePort/ClusterIP
- **Alert rules** - Add custom alerting rules
- **Grafana plugins** - Add additional Grafana plugins

### Common Customizations

1. **Change Grafana admin password**:
   ```yaml
   grafana:
     adminPassword: "your-secure-password"
   ```

2. **Use Ingress instead of LoadBalancer**:
   ```yaml
   grafana:
     service:
       type: ClusterIP
     ingress:
       enabled: true
       hosts:
         - grafana.your-domain.com
   ```

3. **Add Slack alerting**:
   ```yaml
   alertmanager:
     config:
       receivers:
       - name: 'slack'
         slack_configs:
         - api_url: 'YOUR_SLACK_WEBHOOK_URL'
           channel: '#alerts'
   ```

## 🌐 Accessing the Services

### Port Forwarding (Development)

```bash
# Grafana (default: admin/admin)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# Access at http://localhost:3000

# Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Access at http://localhost:9090

# AlertManager
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
# Access at http://localhost:9093
```

### Production Access

For production, consider:
- Setting up Ingress controllers
- Using a proper domain with TLS
- Implementing authentication (OAuth2, LDAP)
- Setting up proper RBAC

## 📈 Using Grafana

### First Steps

1. **Login** with admin/admin (change password on first login)
2. **Explore dashboards** - Click "Dashboards" → "Browse"
3. **View cluster overview** - Start with "Kubernetes / Compute Resources / Cluster"
4. **Check node health** - Use "Node Exporter / Nodes"
5. **Monitor workloads** - Use namespace and workload-specific dashboards

### Creating Custom Dashboards

1. Click "+" → "Dashboard"
2. Add panels with Prometheus queries
3. Save dashboard with meaningful name and tags

### Useful Prometheus Queries

```promql
# Pod memory usage
sum(container_memory_working_set_bytes{pod="YOUR_POD"}) by (container)

# Node CPU usage
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Pod restart count
kube_pod_container_status_restarts_total{namespace="YOUR_NAMESPACE"}

# Available disk space
node_filesystem_avail_bytes{mountpoint="/"}
```

## 🚨 Alerting

### Viewing Alerts

1. In Grafana: "Alerting" → "Alert rules"
2. In Prometheus: http://localhost:9090/alerts
3. In AlertManager: http://localhost:9093

### Adding Custom Alerts

Edit the `additionalPrometheusRulesMap` section in values.yaml or create a separate PrometheusRule resource.

## 🔍 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n monitoring

# View pod logs
kubectl logs -n monitoring <pod-name>

# Describe pod for events
kubectl describe pod -n monitoring <pod-name>
```

### High Resource Usage

If Prometheus uses too much memory:
1. Reduce retention period
2. Increase resource limits
3. Use recording rules for expensive queries
4. Implement metric relabeling to drop unnecessary metrics

### Missing Metrics

1. Check ServiceMonitor is created: `kubectl get servicemonitor -n monitoring`
2. Verify Prometheus can scrape targets: Prometheus UI → Status → Targets
3. Check RBAC permissions for Prometheus

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboard Repository](https://grafana.com/grafana/dashboards/)

## 🧹 Uninstallation

To remove the entire stack:

```bash
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

⚠️ **Warning**: This will delete all data including custom dashboards and historical metrics! 