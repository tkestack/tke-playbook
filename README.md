# TKE Playbook 仓库贡献指南

欢迎来到 TKE Playbook 仓库！本文档将指导您如何向此仓库贡献内容。

## 仓库简介

TKE Playbook 是一个收集和分享 Kubernetes 相关最佳实践、操作手册和故障处理方案的仓库。我们鼓励社区成员贡献自己的经验和知识，帮助更多人更好地使用和管理 Kubernetes 集群。

## 如何贡献

要向此仓库贡献内容，请按照以下步骤操作：

### 1. 准备您的内容目录

首先，创建一个包含您要分享内容的目录。该目录可以包含任何相关文件，如文档、脚本、配置文件等。

### 2. 创建 __meta__.txt 文件

每个贡献的目录必须包含一个名为 `__meta__.txt` 的元数据文件。该文件包含有关您贡献内容的重要信息。

`__meta__.txt` 文件的格式如下：

```
title = ''
description = ''
class = ""
tag = [""]
draft = false

title_en = ''
description_en = ''
class_en = ""
tag_en = [""]
draft = false
```

各字段说明：

- `title`: 中文标题，简要描述您的内容
- `description`: 中文详细描述，详细介绍您的内容
- `class`: 内容分类（例如："TKE"）
- `tag`: 标签列表，用于分类和搜索
- `draft`: 是否为草稿（true/false）
- `title_en`: 英文标题
- `description_en`: 英文详细描述
- `class_en`: 英文内容分类
- `tag_en`: 英文标签列表
- `draft`: 是否为草稿（true/false）

### 3. 示例 __meta__.txt 文件

以下是一个 `__meta__.txt` 文件的示例：

```
title = "Kubernetes故障演练Playbooks指南"
title_en = "Kubernetes Chaos Testing Playbooks Guide"
description = "
K8s中心化架构与声明式管理虽提升运维效率，却因链式故障风险威胁集群稳定性，具体表现为：  
• 级联删除风险：误删namespace可能连带删除核心业务资源（如workload、Pod），导致业务中断。  

• 控制面过载隐患：第三方组件（如DaemonSet监控）可能引发控制面故障，依赖控制面的组件（如coredns、Flink）连锁失效，造成数据面崩溃。  

• 架构脆弱性传导：单点组件异常（如kube-apiserver中断）可通过依赖链引发全局故障，放大故障影响范围。  

为应对上述风险，需通过故障演练提前验证系统韧性，覆盖节点故障、资源误操作、控制面过载等场景，降低故障爆炸半径，保障业务连续性。
"
description_en = "
Kubernetes' centralized architecture and declarative management model, while enabling efficient operations, also introduce critical risks of cascading failures. The open ecosystem (with third-party components like Flink and Rancher) and complex multi-service environments further exacerbate these risks:

Cascading deletion disaster: A customer using Rancher to manage Kubernetes clusters accidentally deleted a namespace, which subsequently deleted all core business workloads and Pods in the production cluster, causing service interruption.
Control plane overload: In a large OpenAI cluster, deploying a DaemonSet monitoring component triggered control plane failures and coredns overload. The coredns scaling depended on control plane recovery, affecting the data plane and causing global OpenAI service disruption.
Data plane's strong dependency on control plane: In open-source Flink on Kubernetes scenarios, kube-apiserver disruption may cause Flink task checkpoint failures and leader election anomalies. In severe cases, it may trigger abnormal exits of all existing task Pods, leading to complete data plane collapse and major incidents.
These cases are not uncommon. The root cause lies in Kubernetes' architecture vulnerability chain - a single component failure or incorrect command can trigger global failures through centralized pathways.

To proactively understand the impact duration and severity of control plane failures on services, we should conduct regular fault simulation and assessments to improve failure response capabilities, ensuring Kubernetes environment stability and reliability.

This project provides Kubernetes chaos testing capabilities covering scenarios like node shutdown, accidental resource deletion, and control plane component (etcd, kube-apiserver, coredns, etc.) overload/disruption, it will help you minimize blast radius of cluster failures.
"
class = "TKE"
tag = ["HA, disaster recovery"]
draft = false
```

### 4. 提交您的内容

准备好内容目录和 `__meta__.txt` 文件后，您可以通过以下方式提交：

1. Fork 此仓库
2. 将您的内容目录添加到仓库中
3. 提交 Pull Request

或者，如果您有直接提交权限，可以直接推送您的更改到仓库。

## 注意事项

- 请确保您的 `__meta__.txt` 文件遵循指定格式
- 保持内容的相关性和质量
- 在提交前检查拼写和语法错误
- 如果内容尚未完成，请将 `draft` 字段设置为 `true`
