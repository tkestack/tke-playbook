# Solution 1: Create TKE Cluster

## Overview

This solution demonstrates how to create a TKE (Tencent Kubernetes Engine) cluster using Terraform.

## File Descriptions

- `cluster.tf` - TKE cluster resource configuration
- `network.tf` - Network-related resource configuration
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

3. Apply configuration to create cluster:
   ```bash
   terraform apply
   ```

4. Get cluster access credentials:
   ```bash
   terraform output kubeconfig
   ```

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
- Ensure your account has sufficient quotas to create clusters
- It is recommended to verify in a test environment before using in production
