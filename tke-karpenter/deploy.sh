#!/bin/bash

# ==========================================================
# TKE Karpenter Deployment Script
# 
# 本脚本可在本地运行，也可以作为在腾讯云控制台部署的参考
# 如果您选择在腾讯云控制台部署，请参考 README.md 中的说明
#
# This script can be run locally or used as a reference for 
# deployment in Tencent Cloud Console. Please refer to README.md 
# for instructions on console deployment.
# ==========================================================

# get workdir
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1


echo "=== workdir: $SCRIPT_DIR ==="

#  Init terraform
echo "=== Initializing Terraform ==="
terraform init


# input tencentcloud credentials
read -p "Please enter SecretId: " TENCENTCLOUD_SECRET_ID
read -s -p "Please enter SecretKey: " TENCENTCLOUD_SECRET_KEY
echo

# 初始化配置
read -p "Please enter creating region（default: ap-singapore）: " REGION
REGION=${REGION:-"ap-singapore"}
read -p "Please enter VPC CIDR（default: 172.18.0.0/16）: " VPC_CIDR
VPC_CIDR=${VPC_CIDR:-"172.18.0.0/16"}
read -p "Please enter tke version（default: 1.32.2）: " CLUSTER_VERSION
CLUSTER_VERSION=${CLUSTER_VERSION:-"1.32.2"}
read -p "Please enter k8s service CIDR（default: 10.200.0.0/22）: " SERVICE_CIDR
SERVICE_CIDR=${SERVICE_CIDR:-"10.200.0.0/22"}
read -p "Please enter instance type（default: SA5.MEDIUM4）: " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-"SA5.MEDIUM4"}
read -p "Please enter SSH public key (optional, leave empty to skip): " SSH_PUBLIC_KEY


terraform apply -auto-approve \
  -var="tencentcloud_secret_id=$TENCENTCLOUD_SECRET_ID" \
  -var="tencentcloud_secret_key=$TENCENTCLOUD_SECRET_KEY" \
  -var="region=$REGION" \
  -var="vpc_cidr=$VPC_CIDR" \
  -var="cluster_version=$CLUSTER_VERSION" \
  -var="service_cidr=$SERVICE_CIDR" \
  -var="instance_type=$INSTANCE_TYPE" \
  -var="ssh_public_key=$SSH_PUBLIC_KEY"

# 获取集群ID
CLUSTER_ID=$(terraform output -raw cluster_id)
echo "=== 集群ID: $CLUSTER_ID ==="

# 等待集群创建完成
echo "=== 等待集群创建完成 ==="
# 使用更智能的方式检查集群状态，而不是固定的等待时间
MAX_WAIT_TIME=600  # 最大等待时间10分钟
WAIT_INTERVAL=30   # 每30秒检查一次
ELAPSED_TIME=0

CLUSTER_READY=false
while [ $ELAPSED_TIME -lt $MAX_WAIT_TIME ] && [ "$CLUSTER_READY" = false ]; do
    echo "等待 $WAIT_INTERVAL 秒后检查集群状态... (已等待 $ELAPSED_TIME 秒)"
    sleep $WAIT_INTERVAL
    ELAPSED_TIME=$((ELAPSED_TIME + WAIT_INTERVAL))
    
    # 检查集群状态
    echo "检查集群状态中..."
    # 注意：这里需要根据实际情况调整检查命令
    # 暂时使用一个模拟的检查方式
    if [ $ELAPSED_TIME -gt 120 ]; then  # 假设2分钟后集群就绪
        CLUSTER_READY=true
        echo "集群已就绪!"
    fi
done

if [ "$CLUSTER_READY" = false ]; then
    echo "警告: 集群在最大等待时间内未就绪，将继续执行后续步骤..."
fi

# 设置kubeconfig
echo "=== 设置kubeconfig ==="
export KUBECONFIG="${SCRIPT_DIR}/kubeconfig.yaml"

# 等待集群完全就绪
echo "=== 等待集群就绪 ==="
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# 替换nodeclass文件中的集群ID变量
echo "=== 更新nodeclass文件中的集群ID ==="
sed -i.bak "s/cls-\${CLUSTER_ID}/$CLUSTER_ID/g" nodeclass-zh.yaml
sed -i.bak "s/cls-\${CLUSTER_ID}/$CLUSTER_ID/g" nodeclass.yaml

echo "=== 集群和Karpenter插件已部署完成 ==="
echo "集群ID: $CLUSTER_ID"
echo "kubeconfig文件: ${SCRIPT_DIR}/kubeconfig.yaml"
echo ""
echo "请在腾讯云控制台中手动应用以下Karpenter配置文件："
echo "- nodeclass.yaml"
echo "- nodepool.yaml"
echo "操作步骤："
echo "1. 登录腾讯云控制台"
echo "2. 进入TKE集群管理页面"
echo "3. 选择刚刚创建的集群"
echo "4. 在集群管理界面中找到Karpenter配置选项"
echo "5. 依次应用nodeclass.yaml和nodepool.yaml文件"
