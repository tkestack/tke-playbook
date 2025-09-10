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
read -p "Please enter VPC name (default: terraform-native-vpc): " VPC_NAME
VPC_NAME=${VPC_NAME:-"terraform-native-vpc"}
read -p "Please enter VPC CIDR (default: 172.18.0.0/16): " VPC_CIDR
VPC_CIDR=${VPC_CIDR:-"172.18.0.0/16"}
read -p "Please enter subnet name (default: terraform-native-subnet): " SUBNET_NAME
SUBNET_NAME=${SUBNET_NAME:-"terraform-native-subnet"}
read -p "Please enter availability zone (default: ap-singapore-1): " AVAILABILITY_ZONE
AVAILABILITY_ZONE=${AVAILABILITY_ZONE:-"ap-singapore-1"}
read -p "Please enter subnet CIDR (default: 172.18.100.0/24): " SUBNET_CIDR
SUBNET_CIDR=${SUBNET_CIDR:-"172.18.100.0/24"}
read -p "Please enter TKE cluster name (default: terraform-native-cluster): " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-"terraform-native-cluster"}
read -p "Please enter TKE version (default: 1.32.2): " CLUSTER_VERSION
CLUSTER_VERSION=${CLUSTER_VERSION:-"1.32.2"}
read -p "Please enter K8s service CIDR (default: 10.200.0.0/22): " SERVICE_CIDR
SERVICE_CIDR=${SERVICE_CIDR:-"10.200.0.0/22"}
read -p "Please enter node pool name (default: terraform-node-pool): " NODEPOOL_NAME
NODEPOOL_NAME=${NODEPOOL_NAME:-"terraform-node-pool"}
read -p "Please enter node count (default: 1): " NODE_COUNT
NODE_COUNT=${NODE_COUNT:-1}
read -p "Please enter instance type (default: SA2.SMALL2): " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-"SA2.SMALL2"}

echo "=== Starting TKE Native Node Cluster Deployment ==="

terraform apply -auto-approve \
  -var="tencentcloud_secret_id=$TENCENTCLOUD_SECRET_ID" \
  -var="tencentcloud_secret_key=$TENCENTCLOUD_SECRET_KEY" \
  -var="region=$REGION" \
  -var="vpc_name=$VPC_NAME" \
  -var="vpc_cidr=$VPC_CIDR" \
  -var="subnet_name=$SUBNET_NAME" \
  -var="availability_zone=$AVAILABILITY_ZONE" \
  -var="subnet_cidr=$SUBNET_CIDR" \
  -var="cluster_name=$CLUSTER_NAME" \
  -var="cluster_version=$CLUSTER_VERSION" \
  -var="service_cidr=$SERVICE_CIDR" \
  -var="nodepool_name=$NODEPOOL_NAME" \
  -var="node_count=$NODE_COUNT" \
  -var="instance_type=$INSTANCE_TYPE"

echo "=== TKE Native Node Cluster Deployment Completed ==="
