#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "=== 工作目录: $SCRIPT_DIR ==="

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
read -p "请输入VPC CIDR（默认: 172.18.0.0/16）: " VPC_CIDR
VPC_CIDR=${VPC_CIDR:-"172.18.0.0/16"}
read -p "请输入TKE版本（默认: 1.32.2）: " CLUSTER_VERSION
CLUSTER_VERSION=${CLUSTER_VERSION:-"1.32.2"}
read -p "请输入K8s服务CIDR（默认: 10.200.0.0/22）: " SERVICE_CIDR
SERVICE_CIDR=${SERVICE_CIDR:-"10.200.0.0/22"}
read -p "请输入实例类型（默认: S5.MEDIUM4）: " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-"S5.MEDIUM4"}

terraform apply -auto-approve \
  -var="tencentcloud_secret_id=$TENCENTCLOUD_SECRET_ID" \
  -var="tencentcloud_secret_key=$TENCENTCLOUD_SECRET_KEY" \
  -var="region=$REGION" \
  -var="vpc_cidr=$VPC_CIDR" \
  -var="cluster_version=$CLUSTER_VERSION" \
  -var="service_cidr=$SERVICE_CIDR" \
  -var="instance_type=$INSTANCE_TYPE"
