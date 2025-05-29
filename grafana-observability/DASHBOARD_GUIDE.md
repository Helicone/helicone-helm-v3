# Grafana Dashboard Setup Guide

## 🚀 Quick Access

**Grafana URL:** http://localhost:3000  
**Login:** admin / admin

## 📊 Available Dashboards

### **Pre-built Kubernetes Dashboards**

Your installation includes 28+ pre-configured dashboards:

#### **Cluster Overview Dashboards:**
- **Kubernetes / Compute Resources / Cluster** - Overall cluster resource usage
- **Kubernetes / Compute Resources / Namespace (Pods)** - Pod-level metrics per namespace  
- **Kubernetes / Compute Resources / Node** - Individual node performance
- **Node Exporter / Nodes** - Detailed node hardware metrics

#### **Application Monitoring:**
- **Kubernetes / Compute Resources / Workload** - Deployment/StatefulSet metrics
- **Kubernetes / Compute Resources / Pod** - Individual pod performance
- **Kubernetes / Namespace (Pods)** - Namespace-focused view

#### **Infrastructure Dashboards:**
- **Prometheus** - Prometheus server metrics
- **AlertManager Overview** - Alert management
- **CoreDNS** - DNS performance metrics

### **Custom Helicone Dashboard**

A custom dashboard specifically for your Helicone application has been created:
- **Helicone Application Dashboard** - Monitors all Helicone pods (web, jawn, clickhouse, postgresql, etc.)

## 🔧 How to Access Dashboards

1. **Log into Grafana** at http://localhost:3000
2. **Click "Dashboards"** in the left sidebar
3. **Browse** to see all available dashboards
4. **Search** for specific dashboards (e.g., "Helicone", "Kubernetes")

## 📥 Importing Community Dashboards

### **Method 1: Via Grafana UI**
1. Go to **"+" → "Import"** in Grafana
2. Enter a **dashboard ID** from [grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards)
3. **Configure** data source (usually "Prometheus")
4. **Save** the dashboard

### **Method 2: Via ConfigMap (Automatic)**
Create a ConfigMap with the `grafana_dashboard: "1"` label:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-custom-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  dashboard.json: |
    {
      # Dashboard JSON content here
    }
```

Apply with: `kubectl apply -f dashboard-configmap.yaml`

## 🌟 Recommended Community Dashboards

### **Node and Cluster Monitoring:**
- **ID: 1860** - Node Exporter Full
- **ID: 3119** - Kubernetes Cluster Monitoring
- **ID: 6417** - Kubernetes Cluster Overview

### **Application Monitoring:**
- **ID: 6336** - Kubernetes Pod Overview  
- **ID: 8588** - Kubernetes Deployment Overview
- **ID: 10856** - PostgreSQL Database

### **Network and Storage:**
- **ID: 11074** - Kubernetes Networking
- **ID: 13502** - Kubernetes Storage

## 🔨 Creating Custom Dashboards

### **1. Using Grafana UI:**
1. **Click "+" → "Dashboard"**
2. **Add Panel** → Choose visualization type
3. **Write PromQL queries** for your metrics
4. **Configure** display options
5. **Save** with meaningful name

### **2. Key Helicone Metrics to Monitor:**

```promql
# Pod CPU Usage
sum(rate(container_cpu_usage_seconds_total{namespace="default", pod=~"helicone-.*"}[5m])) by (pod)

# Pod Memory Usage
sum(container_memory_working_set_bytes{namespace="default", pod=~"helicone-.*"}) by (pod)

# Pod Restart Count
kube_pod_container_status_restarts_total{namespace="default", pod=~"helicone-.*"}

# Running Pod Count
count(kube_pod_info{namespace="default", pod=~"helicone-.*", phase="Running"})

# Network I/O
rate(container_network_receive_bytes_total{namespace="default", pod=~"helicone-.*"}[5m])
rate(container_network_transmit_bytes_total{namespace="default", pod=~"helicone-.*"}[5m])
```

### **3. Dashboard JSON Export/Import:**
- **Export:** Dashboard Settings → JSON Model → Copy
- **Import:** Create ConfigMap or use Grafana UI import

## 🎯 Dashboard Organization Tips

### **Folder Structure:**
- **General** - Default folder for imported dashboards
- **Kubernetes** - K8s infrastructure dashboards  
- **Applications** - Application-specific dashboards
- **Infrastructure** - Node, network, storage dashboards

### **Tagging Best Practices:**
- Use tags like: `kubernetes`, `helicone`, `infrastructure`, `application`
- This helps with dashboard discovery and organization

### **Variables and Templating:**
Add variables for dynamic dashboards:
- **Namespace** - `label_values(kube_pod_info, namespace)`
- **Pod** - `label_values(kube_pod_info{namespace="$namespace"}, pod)`
- **Node** - `label_values(kube_node_info, node)`

## 🚨 Alert Integration

Dashboards can include alert rules. To add alerts:
1. **Edit panel** → Alerting tab
2. **Configure conditions** (thresholds, etc.)
3. **Set up notification channels** (Slack, email, etc.)

## 📚 Useful Resources

- [Grafana Documentation](https://grafana.com/docs/)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Community Dashboards](https://grafana.com/grafana/dashboards/)
- [Kubernetes Monitoring Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)

## 🔄 Maintenance

### **Dashboard Updates:**
- **Manual:** Edit via Grafana UI
- **Automatic:** Update ConfigMap and restart Grafana pod

### **Backup Dashboards:**
```bash
# Export all dashboards
kubectl get configmaps -n monitoring -l grafana_dashboard=1 -o yaml > dashboards-backup.yaml
```

### **Troubleshooting:**
- **Dashboard not appearing:** Check ConfigMap labels and namespace
- **No data:** Verify Prometheus is scraping targets
- **Performance issues:** Reduce query ranges or add recording rules 