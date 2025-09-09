#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "=== 工作目录: $SCRIPT_DIR ==="

# 销毁资源
echo "=== 开始销毁资源 ==="
terraform destroy -auto-approve
