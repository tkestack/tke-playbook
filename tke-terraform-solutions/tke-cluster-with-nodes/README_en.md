# Solution 1: Create TKE Cluster (Native Nodes + Super Nodes)

[中文版本](./README.md)

## Overview

This solution demonstrates how to create a TKE cluster using Terraform, along with native node pool and super nodes.

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

## Notes

- Cluster creation may take 10-15 minutes
- Ensure your account has sufficient quotas to create clusters, native nodes and super nodes
- It is recommended to verify in a test environment before using in production
