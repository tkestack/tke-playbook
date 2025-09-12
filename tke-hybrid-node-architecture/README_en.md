# TKE Cross-AZ Hybrid Node Architecture Practice (Based on Taints and Tolerations)

[中文版本](./README.md)

## Overview

This solution implements best practices for TKE cross-AZ hybrid node architecture through taints and tolerations mechanism. The architecture leverages intelligent scheduling strategies to separate the deployment of core system components and business applications, maximizing the advantages of different node types and achieving efficient resource utilization and flexible scaling capabilities:

- **Core System Addon Deployment**: System components such as CoreDNS and Metrics Server are deployed on super nodes by default, leveraging their cross-AZ features and high availability
- **Business Application Deployment**: Business applications are deployed on native node pools with precise workload distribution control through toleration configurations
- **Traffic Spike Handling**: When native node resources are insufficient, business applications can automatically scale to super nodes without taint restrictions for rapid response
- **Cross-AZ Deployment**: The cluster, native node pools, and super nodes all support deployment across multiple availability zones for higher availability and fault tolerance

This solution has been optimized to use the latest OS version, improved network configuration, and simplified node configuration.

## File Description

- `cluster.tf` - TKE cluster, native node pool and super node resource configuration
- `provider.tf` - Terraform Provider configuration
- `variables.tf` - Variable definition file
- `deploy.sh` - One-click deployment script
- `uninstall.sh` - One-click uninstall script

## Usage

### One-click Deployment (Recommended)
```bash
./deploy.sh
```

### Manual Deployment
1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. View execution plan:
   ```bash
   terraform plan
   ```

3. Apply configuration to create cluster, native node pool and super nodes:
   ```bash
   terraform apply
   ```

4. Get cluster access credentials:
   ```bash
   terraform output kubeconfig
   ```

### View Output Information
After deployment, you can view the following information:
- `terraform output kubeconfig` - Cluster access credentials
- `terraform output cluster_id` - Cluster ID
- `terraform output native_nodepool_id` - Native node pool ID
- `terraform output super_node_id` - Super node ID
- `terraform output super_node_status` - Super node status

### Clean Up Resources

### One-click Uninstall (Recommended)
```bash
./uninstall.sh
```

### Manual Uninstall
```bash
terraform destroy
```

## Architecture Description

### Node Design

#### Super Nodes
- Used to run core system components (such as CoreDNS, Metrics Server, Ingress Controller, etc.)
- Support cross-AZ deployment for high availability
- No taints configured, allowing normal scheduling of system components
- Auto-scaling capability to handle traffic spikes

#### Native Node Pool
- Dedicated to running business application workloads
- Comes with the following taints by default to prevent accidental scheduling of system components:
  - `node-type=native:NoSchedule`
  - `dedicated=business-workload:NoSchedule`
- Auto-scaling is disabled, with manual node count management
- Provides stable computing resources for regular business operations

### Scheduling Strategy

1. **System Components**: Scheduled only to super nodes by default due to taints on native nodes
2. **Business Applications**: Need explicit toleration configuration to be scheduled to native nodes
3. **Traffic Spike Handling**: When native node resources are insufficient, business pods will automatically be scheduled to super nodes

### Business Application Deployment Example

To deploy applications on native nodes, you need to add corresponding toleration configurations in your Pod or Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: business-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: business-app
  template:
    metadata:
      labels:
        app: business-app
    spec:
      # Tolerate the taints on native nodes
      tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "native"
        effect: "NoSchedule"
      - key: "dedicated"
        operator: "Equal"
        value: "business-workload"
        effect: "NoSchedule"
      containers:
      - name: app
        image: nginx:latest
```

## Notes

- Cluster creation may take 10-15 minutes
- Ensure your account has sufficient quotas to create clusters, native nodes and super nodes
- It is recommended to verify in a test environment before using in production
- Auto-scaling for the native node pool is disabled. Please manually adjust the node count according to business needs
