# TKE Cluster Control Plane and Node Upgrade Tool

## Introduction

The TKE Cluster Control Plane and Node Upgrade Tool allows you to upgrade both the control plane and worker nodes of TKE clusters by directly calling Tencent Cloud APIs using the Tencent Cloud Python SDK, without relying on Terraform or complex command-line tools. This tool is designed to simplify the cluster upgrade process.

## Features

- **Simplified Upgrade Process**: Directly call Tencent Cloud APIs using Python SDK to upgrade both cluster control plane and worker nodes
- **Credential Security Management**: Pass credentials via environment variables to avoid hardcoding sensitive information
- **Detailed Error Handling**: Comprehensive error handling mechanism with clear error messages
- **Flexible Configuration**: Support configuring all necessary parameters via environment variables
- **Integrated Upgrade**: Upgrade both control plane and worker nodes in one operation, simplifying maintenance tasks

## Prerequisites

1. Install Python 3:
   - Download and install from [python.org](https://www.python.org/downloads/)

2. Install Tencent Cloud Python SDK:
   ```bash
   pip install tencentcloud-sdk-python
   ```

## Usage

### Configure Environment Variables

Before running the script, you need to configure the necessary environment variables. Please edit the run_updatecluster.sh script and modify the following variables. Note that you should modify these variables directly in the script, rather than setting environment variables in the terminal in advance, as environment variables set in advance may not be correctly read by the script.

```bash
# Set environment variables (please modify according to your actual situation)
export TENCENTCLOUD_SECRET_ID="your_secret_id"
export TENCENTCLOUD_SECRET_KEY="your_secret_key"
export TKE_CLUSTER_ID="cls-xxxxxxxx"
export TKE_TARGET_VERSION="1.30.2"
export TKE_REGION="ap-singapore"
export TKE_UPGRADE_TYPE="reset"
```

### Upgrade Cluster Control Plane

Use the run_updatecluster.sh script to upgrade the control plane:

```bash
./run_updatecluster.sh
```

The script will perform the following operation:
1. Upgrade the cluster control plane

After the control plane upgrade is completed, you can run the following command to upgrade the cluster nodes:

```bash
./upgrade_nodes.sh
```

**Note**: Since cluster upgrades are asynchronous operations, you need to wait for some time after the control plane upgrade is completed before proceeding with node upgrades. Usually you need to wait 10-30 minutes, depending on the size and complexity of the cluster. You can check the upgrade progress through the Tencent Cloud console.

### Manually Set Environment Variables and Run

You can also manually set environment variables and then run the Python script directly (Note: This method requires setting environment variables and running the Python script in the same terminal session):

```bash
export TENCENTCLOUD_SECRET_ID="your_actual_secret_id"
export TENCENTCLOUD_SECRET_KEY="your_actual_secret_key"
export TKE_CLUSTER_ID="your_actual_cluster_id"
export TKE_TARGET_VERSION="your_target_version"
export TKE_REGION="your_region"

python3 updatecluster.py
```

### Environment Variables Description

- `TENCENTCLOUD_SECRET_ID`: Tencent Cloud Secret ID (Required)
- `TENCENTCLOUD_SECRET_KEY`: Tencent Cloud Secret Key (Required)
- `TKE_CLUSTER_ID`: Cluster ID (Required)
- `TKE_TARGET_VERSION`: Target version (Required, e.g., 1.30.2, must be higher than current version)
- `TKE_REGION`: Region (Optional, default: ap-singapore)
- `TKE_UPGRADE_TYPE`: Node upgrade type (Optional, default: reset, options: reset/hot/major)
  - reset: Major version reinstall upgrade (for regular CVM nodes)
  - hot: Minor version hot upgrade (for regular CVM nodes)
  - major: Major version in-place upgrade (for native nodes and super nodes)
- `TKE_SKIP_PRE_CHECK`: Whether to skip pre-check (Optional, default: False, options: True/False)
  - True: Skip pre-check
  - False: Do not skip pre-check (default value, recommended for production environments)

For more detailed information about additional available parameters, please refer to [API Parameters Detailed Explanation](API_PARAMETERS_EN.md) or [API参数详解](API_PARAMETERS.md) (Chinese version).

## Notes

- Please ensure important data is backed up before upgrading
- Ensure your account has sufficient permissions to perform upgrade operations
- Adjust script parameters according to your actual environment
- It is recommended to verify in a test environment before using in production
- The script will upgrade both control plane and worker nodes in sequence, please be patient for completion

## Troubleshooting

If you encounter issues, please check the following:

1. Confirm Python 3 is correctly installed
2. Confirm Tencent Cloud Python SDK is correctly installed
3. Confirm the provided credentials have sufficient permissions
4. Confirm cluster ID and region are correct
5. Check the error messages output by the script

## Supported Kubernetes Versions

- 1.18.x
- 1.20.x
- 1.22.x
- 1.24.x
- 1.26.x
- 1.28.x
- 1.30.x
- 1.32.x

## Supported Regions

- Asia Pacific: Beijing, Shanghai, Guangzhou, Chengdu, Nanjing, Chongqing, Shenzhen, Hong Kong, Singapore, Mumbai, Jakarta, Bangkok, Seoul, Tokyo
- Europe: Frankfurt, Moscow, Warsaw, London, Madrid
- North America: Silicon Valley, Virginia, Toronto
- South America: Sao Paulo
- Middle East: Dubai, Bahrain

## Changelog

### v1.1 (2025-09-24)
- Added support for cluster node upgrade
- Support integrated upgrade of both control plane and worker nodes
- Updated execution script to perform both control plane and node upgrades

### v1.0 (2025-09-24)
- Initial release
- Support upgrading TKE cluster control plane using Tencent Cloud Python SDK
- Provide convenient execution script and detailed usage instructions
