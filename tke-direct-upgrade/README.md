# TKE 集群控制平面和节点升级工具

## 简介

TKE 集群控制平面和节点升级工具允许您使用腾讯云 Python SDK 直接调用腾讯云 API 来升级 TKE 集群的控制平面和工作节点，而无需依赖 Terraform 或复杂的命令行工具。该工具专为简化集群升级流程而设计。

## 功能特点

- **简化升级流程**：使用 Python SDK 直接调用腾讯云 API 完成集群控制平面和节点升级
- **凭据安全管理**：通过环境变量传递凭据，避免硬编码敏感信息
- **详细错误处理**：完善的错误处理机制，提供清晰的错误信息
- **灵活配置**：支持通过环境变量配置所有必要参数
- **一体化升级**：同时升级集群控制平面和工作节点，简化运维操作

## 前提条件

1. 安装 Python 3：
   - 从 [python.org](https://www.python.org/downloads/) 下载安装

2. 安装腾讯云 Python SDK：
   ```bash
   pip install tencentcloud-sdk-python
   ```

## 使用方法

### 配置环境变量

在运行脚本之前，您需要先配置必要的环境变量。请编辑 run_updatecluster.sh 脚本，修改以下变量的值。请注意，您应该在脚本中直接修改这些变量，而不是在终端中提前设置环境变量，因为提前设置的环境变量可能不会被脚本正确读取。

```bash
# 设置环境变量（请根据实际情况修改以下变量）
export TENCENTCLOUD_SECRET_ID="your_secret_id"
export TENCENTCLOUD_SECRET_KEY="your_secret_key"
export TKE_CLUSTER_ID="cls-xxxxxxxx"
export TKE_TARGET_VERSION="1.30.2"
export TKE_REGION="ap-singapore"
export TKE_UPGRADE_TYPE="reset"
```

### 升级集群控制平面

使用 run_updatecluster.sh 脚本进行控制平面升级：

```bash
./run_updatecluster.sh
```

脚本将执行以下操作：
1. 升级集群控制平面

控制平面升级完成后，您可以运行以下命令升级集群节点：

```bash
./upgrade_nodes.sh
```

**注意**：由于集群升级是异步操作，控制平面升级完成后需要等待一段时间才能进行节点升级。通常需要等待10-30分钟，具体时间取决于集群的大小和复杂性。您可以通过腾讯云控制台查看升级进度。

### 手动设置环境变量并运行

您也可以手动设置环境变量后直接运行 Python 脚本（注意：这种方式需要在同一个终端会话中先设置环境变量，再运行Python脚本）：

```bash
export TENCENTCLOUD_SECRET_ID="your_actual_secret_id"
export TENCENTCLOUD_SECRET_KEY="your_actual_secret_key"
export TKE_CLUSTER_ID="your_actual_cluster_id"
export TKE_TARGET_VERSION="your_target_version"
export TKE_REGION="your_region"

python3 updatecluster.py
```

### 环境变量说明

- `TENCENTCLOUD_SECRET_ID`：腾讯云 Secret ID（必填）
- `TENCENTCLOUD_SECRET_KEY`：腾讯云 Secret Key（必填）
- `TKE_CLUSTER_ID`：集群 ID（必填）
- `TKE_TARGET_VERSION`：目标版本（必填，如1.30.2，需高于当前版本）
- `TKE_REGION`：区域（可选，默认：ap-singapore）
- `TKE_UPGRADE_TYPE`：节点升级类型（可选，默认：reset，可选值：reset/hot/major）
  - reset: 大版本重装升级（适用于普通CVM节点）
  - hot: 小版本热升级（适用于普通CVM节点）
  - major: 大版本原地升级（适用于原生节点和超级节点）
- `TKE_SKIP_PRE_CHECK`：是否跳过预检查（可选，默认：False，可选值：True/False）
  - True: 跳过预检查
  - False: 不跳过预检查（默认值，推荐用于生产环境）

有关更多可用参数的详细信息，请参阅 [API参数详解](API_PARAMETERS.md) 或 [API Parameters Detailed Explanation](API_PARAMETERS_EN.md)（英文版）。

## 注意事项

- 升级前请确保已备份重要数据
- 确保您的账户具有足够的权限执行升级操作
- 请根据实际环境调整脚本中的参数
- 在生产环境中使用前建议先在测试环境中验证
- 脚本将依次升级控制平面和节点，请耐心等待完成

## 故障排除

如果遇到问题，请检查以下几点：

1. 确认 Python 3 已正确安装
2. 确认腾讯云 Python SDK 已正确安装
3. 确认提供的凭据具有足够权限
4. 确认集群 ID 和区域正确
5. 查看脚本输出的错误信息

## 支持的 Kubernetes 版本

- 1.18.x
- 1.20.x
- 1.22.x
- 1.24.x
- 1.26.x
- 1.28.x
- 1.30.x
- 1.32.x

## 支持的区域

- 亚太地区：北京、上海、广州、成都、南京、重庆、深圳、香港、新加坡、孟买、雅加达、曼谷、首尔、东京
- 欧洲地区：法兰克福、莫斯科、华沙、伦敦、马德里
- 北美地区：硅谷、弗吉尼亚、多伦多
- 南美地区：圣保罗
- 中东地区：迪拜、巴林

## 更新日志

### v1.1 (2025-09-24)
- 新增支持集群节点升级功能
- 支持一体化升级集群控制平面和工作节点
- 更新执行脚本，可同时执行控制平面和节点升级

### v1.0 (2025-09-24)
- 初始版本发布
- 支持使用腾讯云 Python SDK 升级 TKE 集群控制平面
- 提供便捷的执行脚本和详细的使用说明
