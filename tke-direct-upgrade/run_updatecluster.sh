#!/bin/bash

# TKE集群控制平面升级脚本
# 使用Python SDK方式调用TKE API

# 检查必需命令
if ! command -v python3 &> /dev/null; then
    echo "错误：未安装python3"
    exit 1
fi

# 检查Python SDK是否安装
if ! python3 -c "import tencentcloud" &> /dev/null; then
    echo "错误：未安装腾讯云Python SDK"
    echo "请执行：pip install tencentcloud-sdk-python"
    exit 1
fi

# 检查脚本文件
if [ ! -f "updatecluster.py" ]; then
    echo "错误：找不到updatecluster.py文件"
    exit 1
fi

# 设置环境变量（请根据实际情况修改以下变量）
export TENCENTCLOUD_SECRET_ID=""
export TENCENTCLOUD_SECRET_KEY=""
export TKE_CLUSTER_ID="cls-xxx"
export TKE_TARGET_VERSION="1.30.0"
export TKE_REGION="ap-singapore"
export TKE_SKIP_PRE_CHECK="False"

# 执行Python脚本
echo "开始执行集群控制平面升级..."
python3 updatecluster.py

echo "控制平面升级请求已发送，请等待升级完成后再执行节点升级。"
echo "您可以稍后运行 ./upgrade_nodes.sh 来升级集群节点。"
