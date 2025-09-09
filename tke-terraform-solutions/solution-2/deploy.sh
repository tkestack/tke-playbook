#!/bin/bash

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "=== Working Directory: $SCRIPT_DIR ==="

# Initialize Terraform
echo "=== Initializing Terraform ==="
terraform init

# Input Tencent Cloud credentials
read -p "Please enter SecretId: " TENCENTCLOUD_SECRET_ID
read -s -p "Please enter SecretKey: " TENCENTCLOUD_SECRET_KEY
echo

# Initialize configuration
read -p "Please enter region (default: ap-singapore): " REGION
REGION=${REGION:-"ap-singapore"}
read -p "Please enter VPC CIDR (default: 172.18.0.0/16): " VPC_CIDR
VPC_CIDR=${VPC_CIDR:-"172.18.0.0/16"}
read -p "Please enter TKE version (default: 1.32.2): " CLUSTER_VERSION
CLUSTER_VERSION=${CLUSTER_VERSION:-"1.32.2"}
read -p "Please enter K8s service CIDR (default: 10.200.0.0/22): " SERVICE_CIDR
SERVICE_CIDR=${SERVICE_CIDR:-"10.200.0.0/22"}
read -p "Please enter instance type (default: S5.MEDIUM4): " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-"S5.MEDIUM4"}

echo "=== Starting TKE Native Node Cluster Deployment ==="

terraform apply -auto-approve \
  -var="tencentcloud_secret_id=$TENCENTCLOUD_SECRET_ID" \
  -var="tencentcloud_secret_key=$TENCENTCLOUD_SECRET_KEY" \
  -var="region=$REGION" \
  -var="vpc_cidr=$VPC_CIDR" \
  -var="cluster_version=$CLUSTER_VERSION" \
  -var="service_cidr=$SERVICE_CIDR" \
  -var="instance_type=$INSTANCE_TYPE"

echo "=== TKE Native Node Cluster Deployment Completed ==="
