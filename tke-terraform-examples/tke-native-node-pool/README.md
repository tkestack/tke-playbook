# 创建 TKE 原生节点集群

[English Version](./README_en.md)

## 概述

通过Terraform工具创建完整的TKE集群并添加原生节点池，涵盖环境初始化、集群创建、原生节点池创建（执行terraform apply）及资源清理（执行terraform destroy）全流程，验证Terraform对TKE原生节点集群的自动化管理能力。此方案已优化以使用最新的操作系统版本、改进的网络配置和简化的节点配置。

## 文件说明

- `nodepool_native.tf` - TKE 集群和原生节点池资源配置
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

3. 应用配置创建集群和原生节点池:
   ```bash
   terraform apply
   ```

### 清理资源

### 一键卸载（推荐）
```bash
./uninstall.sh
```

### 手动卸载
```bash
terraform destroy
```

## 注意事项

1. 运行过程中如果有tf报错，可以开启tf debug查看具体报错信息，开启方法是设置环境变量，之后可以在terraform.log具体查看debug日志
   ```
   export TF_LOG=DEBUG
   export TF_LOG_PATH=./terraform.log
   ```

2. 注意terraform里原生节点池文档里有一些字段是forenew属性，比如计费字段charge_type，tf文件里该字段修改会导致整个节点池删除重建。创建节点池的时候把这些forcenew字段确认好，之后执行terraform apply的tf文件不要改动这些字段

## 准备

1. 在工作目录创建好nodepool_native.tf、provider.tf和variables.tf文件
2. tf原生节点字段说明：[Terraform Registry](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/kubernetes_native_node_pool)
