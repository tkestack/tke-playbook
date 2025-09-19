# TKE Karpenter 自动伸缩解决方案

[English Version](./README_en.md)

## 概述

本方案通过集成 Karpenter 实现 TKE 集群的智能节点自动伸缩功能。Karpenter 是一种开源的 Kubernetes 节点自动伸缩器，它能够根据工作负载的需求快速、高效地启动和终止节点，从而优化资源利用率并降低成本。

该解决方案具有以下优势：

- **快速响应**：相比传统的水平节点自动伸缩器，Karpenter 能够更快地响应工作负载的变化
- **成本优化**：通过智能调度和及时释放空闲节点，最大化资源利用率
- **灵活性**：支持多种实例类型和可用区，自动选择最合适的节点配置
- **简化管理**：减少对预定义节点组的依赖，实现更灵活的节点管理

## 文件说明

- `cluster.tf` - TKE 集群和原生节点池资源配置
- `network.tf` - VPC、子网和安全组资源配置
- `provider.tf` - Terraform Provider 配置
- `variables.tf` - 变量定义文件
- `nodeclass.yaml` - Karpenter 节点类配置
- `nodepool.yaml` - Karpenter 节点池配置
- `deploy.sh` - 一键部署脚本
- `uninstall.sh` - 一键卸载脚本

## 使用方法

### 本地部署（推荐）

本方案设计为在本地执行部署脚本，创建TKE集群和Karpenter插件。Karpenter的详细配置（nodeclass.yaml和nodepool.yaml）需要用户在腾讯云控制台手动应用。

1. 安装 Terraform (推荐版本 1.0+)
2. 安装 kubectl
3. 获取腾讯云访问密钥 (SecretId 和 SecretKey)
4. 确保账户有足够的配额来创建集群和节点

执行部署脚本：
```bash
./deploy.sh
```

脚本会执行以下操作：

1. **初始化工作目录**：切换到脚本所在目录
2. **初始化 Terraform**：执行 `terraform init` 命令
3. **收集用户输入**：提示用户输入配置信息（SecretId、SecretKey、区域、VPC CIDR等）
4. **应用 Terraform 配置**：使用用户提供的参数执行 `terraform apply` 命令创建集群和相关资源
5. **等待集群创建完成**：通过轮询检查集群状态，最长等待10分钟
6. **设置 kubeconfig**：配置 Kubernetes 访问凭证
7. **等待节点就绪**：使用 `kubectl wait` 命令确保所有节点都处于就绪状态
8. **更新 Karpenter 配置**：将集群ID替换到 nodeclass.yaml 和 nodepool.yaml 文件中

脚本执行完成后，您将拥有一个完全配置好的 TKE 集群，集成了 Karpenter 自动伸缩插件。

### 手动应用 Karpenter 配置

部署脚本执行完成后，您需要在腾讯云控制台手动应用Karpenter配置：

1. 登录腾讯云控制台
2. 进入TKE集群管理页面
3. 选择刚刚创建的集群
4. 在集群管理界面中找到Karpenter配置选项
5. 依次应用以下文件：
   - `nodeclass.yaml` - Karpenter 节点类配置
   - `nodepool.yaml` - Karpenter 节点池配置

这样设计的好处是：
- 简化了本地部署流程，部署脚本只需关注集群和插件的创建
- 用户可以根据实际需求在控制台中灵活调整Karpenter配置
- 避免了用户需要在本地安装和配置kubectl工具的复杂性

### 配置 Karpenter

部署完成后，需要应用 Karpenter 配置：

1. 设置 kubeconfig:
   ```bash
   export KUBECONFIG=/path/to/kubeconfig.yaml
   ```

2. 应用 Karpenter 配置:
   ```bash
   kubectl apply -f nodeclass.yaml
   kubectl apply -f nodepool.yaml
   ```

### 查看输出信息

部署完成后，可以查看以下信息：
- `terraform output cluster_id` - 集群ID
- `terraform output kubeconfig` - 集群访问凭证文件路径

### 清理资源

#### 一键卸载（推荐）
```bash
./uninstall.sh
```

#### 手动卸载
```bash
terraform destroy
```

## 架构说明

### 组件介绍

#### TKE 集群
- 创建一个托管的 TKE 集群
- 启用 Karpenter 扩展插件
- 配置 VPC-CNI 网络模式

#### 原生节点池
- 创建一个初始的原生节点池，用于运行 Karpenter 控制器和其他必要的系统组件
- 配置自动伸缩范围（最小2个节点，最大6个节点）

#### Karpenter 配置
- **NodeClass**: 定义节点的基础设施属性，如子网、安全组、SSH 密钥等
- **NodePool**: 定义节点的调度约束和资源限制

### 工作原理

1. 当工作负载需要更多资源时，Karpenter 会根据 NodePool 中定义的约束条件选择合适的节点类型
2. Karpenter 直接与云提供商 API 交互，快速启动新的节点实例
3. 新节点加入集群后，Karpenter 将待处理的 Pod 调度到新节点上
4. 当节点长时间处于低利用率状态时，Karpenter 会优雅地终止这些节点以节省成本

## 配置说明

### 主要变量

- `region`: 集群所在的区域
- `vpc_cidr`: VPC 的 CIDR 块
- `cluster_version`: Kubernetes 版本
- `service_cidr`: Kubernetes Service CIDR
- `instance_type`: 节点实例类型
- `ssh_public_key`: SSH 公钥（可选）

### Karpenter 配置

#### NodeClass 配置
```yaml
apiVersion: karpenter.k8s.tke/v1beta1
kind: TKEMachineNodeClass
metadata:
  name: default
spec:
  # 公网带宽配置
  internetAccessible:
    chargeType: TrafficPostpaidByHour
    maxBandwidthOut: 2

  # 系统盘配置
  systemDisk:
    size: 60
    type: CloudPremium

  # 数据盘配置
  dataDisks:
  - mountTarget: /var/lib/containerd
    size: 50
    type: CloudPremium
    fileSystem: ext4

  # 子网选择
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: cls-${CLUSTER_ID}

  # 安全组选择
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: cls-${CLUSTER_ID}

  # SSH 密钥选择
  sshKeySelectorTerms:
    - tags:
        karpenter.sh/discovery: cls-${CLUSTER_ID}
```

#### NodePool 配置
```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: test
spec:
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 5m
    budgets:
    - nodes: 10%
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.k8s.tke/instance-family
          operator: In
          values: ["S5","SA2"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: "karpenter.k8s.tke/instance-cpu"
          operator: Gt
          values: ["1"]
      nodeClassRef:
        group: karpenter.k8s.tke
        kind: TKEMachineNodeClass
        name: default
  limits:
    cpu: 10
```

## 触发条件和使用方法

### 节点自动扩容触发条件

Karpenter 会在以下情况下自动创建新节点：

1. **资源不足**：当Pod因资源不足（CPU、内存等）而无法调度时
2. **节点选择器匹配**：当Pod的nodeSelector或nodeAffinity与现有节点不匹配时
3. **污点容忍**：当Pod的tolerations无法与现有节点的taints匹配时
4. **拓扑分布约束**：当Pod的topologySpreadConstraints无法满足时

### 节点自动缩容触发条件

Karpenter 会在以下情况下自动终止节点：

1. **节点空闲**：节点在连续5分钟内没有运行任何Pod（除了系统Pod）
2. **节点利用率低**：节点资源利用率持续较低，且可以通过重新调度Pod到其他节点来优化资源使用
3. **生存时间到期**：节点达到最大生存时间（如果配置了ttlSecondsUntilExpired）

### 使用示例

#### 1. 部署应用并观察自动扩容

创建一个资源需求较大的应用：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            cpu: "1"
            memory: "1Gi"
```

应用配置：
```bash
kubectl apply -f sample-app.yaml
```

观察节点自动扩容：
```bash
kubectl get nodes -w
```

#### 2. 观察自动缩容

减少应用副本数：
```bash
kubectl scale deployment sample-app --replicas=0
```

观察节点自动缩容（约5分钟后）：
```bash
kubectl get nodes -w
```

#### 3. 查看Karpenter日志

监控Karpenter决策过程：
```bash
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter -f
```

## 注意事项

- 创建集群可能需要 10-15 分钟时间
- 确保账户有足够的配额来创建集群和节点
- 建议在生产环境中使用前先在测试环境中验证
- SSH 密钥是可选的，但如果提供将有助于节点故障排查
- Karpenter 的自动伸缩功能需要在应用工作负载后才会触发
