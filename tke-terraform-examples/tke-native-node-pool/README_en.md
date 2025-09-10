# TKE Native Node Pool Solution

[中文版本](./README.md)

This solution demonstrates how to create a Tencent Kubernetes Engine (TKE) cluster with native node pools using Terraform. This solution has been optimized to use the latest OS version, improved network configuration, and simplified node configuration.

## Features

- Creates a VPC and subnet for the TKE cluster
- Configures security groups with essential rules (SSH, ICMP)
- Deploys a managed TKE cluster
- Sets up native node pools with autoscaling capabilities
- Provides outputs for cluster access information

## Prerequisites

- Terraform 1.0+
- Tencent Cloud account with appropriate permissions
- Tencent Cloud SecretId and SecretKey
- Sufficient resource quotas in your Tencent Cloud account

## Usage

1. Clone this repository
2. Navigate to this directory
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Configure your Tencent Cloud credentials:
   ```bash
   export TENCENTCLOUD_SECRET_ID="your_secret_id"
   export TENCENTCLOUD_SECRET_KEY="your_secret_key"
   ```
5. Deploy the infrastructure:
   ```bash
   ./deploy.sh
   ```
   Or manually:
   ```bash
   terraform apply
   ```

## Architecture Overview

This solution creates the following resources:

1. **VPC**: A virtual private cloud for network isolation
2. **Subnet**: A subnet within the VPC for cluster resources
3. **Security Group**: Network access control for cluster nodes
4. **TKE Cluster**: Managed Kubernetes cluster
5. **Native Node Pool**: Scalable worker nodes for running workloads

## Customization

You can customize the deployment by modifying the variables in `variables.tf`:

- `region`: Tencent Cloud region for deployment
- `vpc_name`: Name of the VPC
- `vpc_cidr`: CIDR block for the VPC
- `subnet_name`: Name of the subnet
- `availability_zone`: Availability zone for resources
- `cluster_name`: Name of the TKE cluster
- `cluster_version`: Kubernetes version
- `nodepool_name`: Name of the node pool
- `node_count`: Initial number of nodes
- `instance_type`: Node instance type

## Cleanup

To remove all resources created by this solution:

```bash
./uninstall.sh
```

Or manually:

```bash
terraform destroy
```

## Troubleshooting

Common issues and solutions:

1. **Authentication errors**: Verify your SecretId and SecretKey are correct
2. **Quota limitations**: Check your Tencent Cloud resource quotas
3. **CIDR conflicts**: Ensure VPC CIDR doesn't conflict with existing networks

## Contributing

Contributions are welcome! Please submit issues and pull requests to improve this solution.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
