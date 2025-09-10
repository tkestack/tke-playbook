#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "=== 工作目录: $SCRIPT_DIR ==="
echo "=== 开始部署TKE集群（原生节点 + 超级节点） ==="

# 初始化Terraform
echo "=== 初始化Terraform ==="
terraform init

# 输入腾讯云凭证
read -p "请输入SecretId: " TENCENTCLOUD_SECRET_ID
read -s -p "请输入SecretKey: " TENCENTCLOUD_SECRET_KEY
echo

# 初始化配置
read -p "请输入创建区域（默认: ap-singapore）: " REGION
REGION=${REGION:-"ap-singapore"}
read -p "请输入VPC名称（默认: terraform-test-vpc）: " VPC_NAME
VPC_NAME=${VPC_NAME:-"terraform-test-vpc"}
read -p "请输入VPC CIDR（默认: 172.18.0.0/16）: " VPC_CIDR
VPC_CIDR=${VPC_CIDR:-"172.18.0.0/16"}
read -p "请输入子网名称（默认: terraform-test-subnet）: " SUBNET_NAME
SUBNET_NAME=${SUBNET_NAME:-"terraform-test-subnet"}
read -p "请输入可用区（默认: ap-singapore-1）: " AVAILABILITY_ZONE
AVAILABILITY_ZONE=${AVAILABILITY_ZONE:-"ap-singapore-1"}
read -p "请输入子网CIDR（默认: 172.18.100.0/24）: " SUBNET_CIDR
SUBNET_CIDR=${SUBNET_CIDR:-"172.18.100.0/24"}
read -p "请输入TKE集群名称（默认: terraform-test-cluster）: " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-"terraform-test-cluster"}
read -p "请输入TKE版本（默认: 1.32.2）: " CLUSTER_VERSION
CLUSTER_VERSION=${CLUSTER_VERSION:-"1.32.2"}
read -p "请输入K8s服务CIDR（默认: 10.200.0.0/22）: " SERVICE_CIDR
SERVICE_CIDR=${SERVICE_CIDR:-"10.200.0.0/22"}
read -p "请输入原生节点池名称（默认: terraform-node-pool）: " NODEPOOL_NAME
NODEPOOL_NAME=${NODEPOOL_NAME:-"terraform-node-pool"}
read -p "请输入节点数量（默认: 1）: " NODE_COUNT
NODE_COUNT=${NODE_COUNT:-1}
read -p "请输入实例类型（默认: S5.MEDIUM4）: " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-"S5.MEDIUM4"}
read -p "请输入超级节点名称（默认: terraform-super-node）: " SUPER_NODE_NAME
SUPER_NODE_NAME=${SUPER_NODE_NAME:-"terraform-super-node"}

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
  -var="instance_type=$INSTANCE_TYPE" \
  -var="super_node_name=$SUPER_NODE_NAME"

echo "=== TKE集群（原生节点 + 超级节点）部署完成 ==="
