#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "=== 工作目录: $SCRIPT_DIR ==="
echo "=== 开始销毁TKE集群（原生节点 + 超级节点）资源 ==="

# 输入腾讯云凭证
read -p "请输入SecretId: " TENCENTCLOUD_SECRET_ID
read -s -p "请输入SecretKey: " TENCENTCLOUD_SECRET_KEY
echo

terraform destroy -auto-approve \
  -var="tencentcloud_secret_id=$TENCENTCLOUD_SECRET_ID" \
  -var="tencentcloud_secret_key=$TENCENTCLOUD_SECRET_KEY"

echo "=== TKE集群（原生节点 + 超级节点）资源销毁完成 ==="
