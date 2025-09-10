# TKE NginxIngress 组件迁移到自建 Ingress-nginx 指南

[English Version](./README_en.md)

## 背景
TKE NginxIngress 扩展组件已不再支持 TKE 1.30 及以上版本。若需升级集群版本至 1.30 或更高，需移除低版本集群中的 TKE NginxIngress 扩展组件，并切换至社区版 Ingress-nginx。

为了实现现网流量的无损切换，本文档提供了两种不同的迁移方案，帮助用户根据自身需求选择最适合的方式，顺利完成 TKE NginxIngress 的切换升级，确保业务流量平稳过渡。

## 迁移方案对比

### 方案一：独立 IngressClass 方式（推荐）
- **目录**：[tke-migrate-to-community-ingress](tke-migrate-to-community-ingress/)
- **核心思想**：创建全新的 IngressClass，与原有 TKE IngressClass 完全独立
- **特点**：
  - 新旧控制器完全隔离，互不影响
  - 通过 DNS 切换来实现流量切换
  - 迁移过程最为安全，回滚简单
  - 适合对稳定性要求极高的生产环境

### 方案二：共享 IngressClass 方式
- **目录**：[tke-install-community-ingress](tke-install-community-ingress/)
- **核心思想**：复用原有的 IngressClass，新旧控制器共享同一 IngressClass
- **特点**：
  - 无需修改现有的 Ingress 资源
  - 通过权重调整实现流量切换
  - 配置相对复杂，需要精确控制
  - 适合希望最小化配置变更的场景

## 方案详细说明

### 方案一：独立 IngressClass 方式

在此方案中，我们部署两个完全独立的 Ingress controller：
- 保留原有的 TKE NginxIngress controller（使用 IngressClass `test`）
- 部署新的社区版 Ingress-nginx controller（使用 IngressClass `new-test`）

两个控制器独立运行，通过修改 DNS 解析将流量从旧控制器切换到新控制器。

**优势**：
- 隔离性好，新旧环境互不影响
- 迁移过程风险最低
- 回滚操作简单直接
- 便于监控和调试

**适用场景**：
- 生产环境迁移
- 对业务连续性要求极高的场景
- 首次进行此类迁移的用户

### 方案二：共享 IngressClass 方式

在此方案中，我们让新的社区版 Ingress-nginx controller 复用原有的 IngressClass：
- 保留原有的 TKE NginxIngress controller（使用 IngressClass `test`）
- 部署新的社区版 Ingress-nginx controller（同样使用 IngressClass `test`）
- 通过权重配置控制流量分配

两个控制器共享同一 IngressClass，通过调整权重实现流量切换。

**优势**：
- 无需修改现有 Ingress 资源
- 配置变更最小化
- 可以实现渐进式迁移

**适用场景**：
- 希望最小化配置变更的场景
- 需要渐进式迁移的环境
- 对 Ingress 资源数量较多且不便于逐个修改的情况

## 使用指南

### 选择合适的方案
1. **方案一**：如果你追求最高的安全性和最简单的回滚操作，推荐使用方案一
2. **方案二**：如果你希望最小化配置变更且能够接受稍复杂的配置，可以选择方案二

### 实施步骤
无论选择哪种方案，基本的实施步骤都是相似的：

1. **环境准备**：部署模拟的 TKE NginxIngress 组件环境
2. **新控制器部署**：根据所选方案部署新的 Ingress-nginx controller
3. **平滑迁移**：通过 DNS 切换或权重调整实现流量迁移
4. **验证确认**：验证迁移后的服务稳定性和可用性

### 注意事项
- 两种方案都需要 Kubernetes 版本 >= 1.14 且 <= 1.28
- 迁移过程中建议密切监控业务指标
- 建议在业务低峰期进行迁移操作
- 准备好回滚方案以应对意外情况

## 目录结构
```
tke-to-community-ingress/
├── tke-migrate-to-community-ingress/           # 方案一：独立 IngressClass 方式
│   ├── README.md         # 方案一详细说明
│   ├── values.yaml       # Helm 配置文件
│   ├── install-tke-ingress.sh     # 部署 TKE Ingress 脚本
│   ├── install-community-ingress.sh  # 部署社区 Ingress 脚本
│   └── migrate.sh        # 迁移脚本
└── tke-install-community-ingress/           # 方案二：共享 IngressClass 方式
    ├── README.md         # 方案二详细说明
    ├── values.yaml       # Helm 配置文件
    ├── install-tke-ingress.sh     # 部署 TKE Ingress 脚本
    ├── install-community-ingress.sh  # 部署社区 Ingress 脚本
    └── migrate.sh        # 迁移脚本
```

选择适合您需求的方案，进入对应目录查看详细的实施步骤和配置说明。
