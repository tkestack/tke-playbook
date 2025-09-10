# TKE Terraform Solutions

[中文版本](./README.md)

## Overview

This guide provides comprehensive solutions for managing TKE clusters, native nodes, and super nodes using Terraform. Through this guide, you can learn how to implement full lifecycle management of Kubernetes cluster resources using Terraform.

## Solution Directory

| Solution | Description |
|----------|-------------|
| [tke-cluster-with-nodes: Create TKE Cluster (Native Nodes + Super Nodes)](./tke-cluster-with-nodes) | Create a TKE cluster using Terraform, along with native node pool and super nodes |
| [tke-native-node-pool: Create TKE Native Node Cluster](./tke-native-node-pool) | Create a complete TKE cluster and add native node pools using Terraform |
| [tke-super-node-pool: Create TKE Super Node Cluster](./tke-super-node-pool) | Create a complete TKE cluster and add super nodes using Terraform |

## Prerequisites

1. Install Terraform (recommended version 1.0+)
2. Obtain Tencent Cloud access credentials (SecretId and SecretKey)
3. Configure Tencent Cloud credentials:
   ```bash
   export TENCENTCLOUD_SECRET_ID=your_secret_id
   export TENCENTCLOUD_SECRET_KEY=your_secret_key
   export TENCENTCLOUD_REGION=your_region  # e.g., ap-beijing
   ```

## Usage

1. Select the solution directory that fits your needs
2. Navigate to the corresponding directory and initialize Terraform:
   ```bash
   cd solution-X
   terraform init
   ```
3. Review the execution plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```
5. Clean up resources (optional):
   ```bash
   terraform destroy
   ```

## Notes

1. Please read the detailed instructions for each solution carefully before using in production environments
2. Some fields are forcenew attributes, and modification will cause resource recreation
3. It is recommended to enable Terraform logging for debugging:
   ```bash
   export TF_LOG=DEBUG
   export TF_LOG_PATH=./terraform.log
   ```

## Contributing

Feel free to submit Issues and Pull Requests to improve this guide.
