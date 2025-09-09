# Solution 1: 创建 TKE 集群

## 概述

本方案演示如何使用 Terraform 创建 TKE 集群。

## 文件说明

- `cluster.tf` - TKE 集群资源配置
- `network.tf` - 网络相关资源配置
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

3. 应用配置创建集群:
   ```bash
   terraform apply
   ```

4. 获取集群访问凭证:
   ```bash
   terraform output kubeconfig
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

- 创建集群可能需要 10-15 分钟时间
- 确保账户有足够的配额来创建集群
- 建议在生产环境中使用前先在测试环境中验证
