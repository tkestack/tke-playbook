# TKE 跨可用区混合节点架构实践（基于污点和容忍机制）

[English Version](./README_en.md)

## 概述

本方案通过污点和容忍机制实现TKE跨可用区混合节点架构的最佳实践。该架构利用智能调度策略，将核心系统组件和业务应用分离部署，充分发挥不同节点类型的优势，实现高效的资源利用和灵活的扩展能力：

- **核心系统Addon部署**：CoreDNS、Metrics Server等系统组件默认部署在超级节点上，利用其跨可用区特性和高可用性
- **业务应用部署**：业务应用默认部署在原生节点池，通过容忍配置精确控制工作负载分布
- **突发流量处理**：当原生节点资源不足时，业务应用可自动扩展到无污点限制的超级节点，实现快速响应
- **跨可用区部署**：集群、原生节点池和超级节点均支持跨多个可用区部署，提供更高的可用性和容错能力

此方案已优化以使用最新的操作系统版本、改进的网络配置和简化的节点配置。

## 文件说明

- `cluster.tf` - TKE 集群、原生节点池和超级节点资源配置
- `provider.tf` - Terraform Provider 配置
- `variables.tf` - 变量定义文件
- `deploy.sh` - 一键部署脚本
- `uninstall.sh` - 一键卸载脚本

## 使用方法

### 一键部署（推荐）
```bash
./deploy.sh
```

### 手动部署
1. 初始化 Terraform:
   ```bash
   terraform init
   ```

2. 查看执行计划:
   ```bash
   terraform plan
   ```

3. 应用配置创建集群、原生节点池和超级节点:
   ```bash
   terraform apply
   ```

4. 获取集群访问凭证:
   ```bash
   terraform output kubeconfig
   ```

### 查看输出信息
部署完成后，可以查看以下信息：
- `terraform output kubeconfig` - 集群访问凭证
- `terraform output cluster_id` - 集群ID
- `terraform output native_nodepool_id` - 原生节点池ID
- `terraform output super_node_id` - 超级节点ID
- `terraform output super_node_status` - 超级节点状态

### 清理资源

### 一键卸载（推荐）
```bash
./uninstall.sh
```

### 手动卸载
```bash
terraform destroy
```

## 架构说明

### 节点设计

#### 超级节点（Super Node）
- 用于运行核心系统组件（如 CoreDNS、Metrics Server、Ingress Controller 等）
- 支持跨可用区部署，提供高可用性
- 无污点配置，可正常调度系统组件
- 自动扩缩容能力，应对突发流量

#### 原生节点池（Native Node Pool）
- 专门用于运行业务应用工作负载
- 默认配置了以下污点防止系统组件意外调度：
  - `node-type=native:NoSchedule`
  - `dedicated=business-workload:NoSchedule`
- 自动扩容已关闭，由用户手动管理节点数量
- 提供稳定的计算资源用于常规业务

### 调度策略

1. **系统组件**：默认只会调度到超级节点，因为原生节点有污点
2. **业务应用**：需要显式配置容忍（tolerations）才能调度到原生节点
3. **突发流量处理**：当原生节点资源不足时，业务Pod会自动调度到超级节点

### 业务应用部署示例

要在原生节点上部署应用，需要在Pod或Deployment中添加相应的容忍配置：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: business-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: business-app
  template:
    metadata:
      labels:
        app: business-app
    spec:
      # 容忍原生节点的污点
      tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "native"
        effect: "NoSchedule"
      - key: "dedicated"
        operator: "Equal"
        value: "business-workload"
        effect: "NoSchedule"
      containers:
      - name: app
        image: nginx:latest
```

## 注意事项

- 创建集群可能需要 10-15 分钟时间
- 确保账户有足够的配额来创建集群、原生节点和超级节点
- 建议在生产环境中使用前先在测试环境中验证
- 原生节点池的自动扩容已关闭，请根据业务需求手动调整节点数量
