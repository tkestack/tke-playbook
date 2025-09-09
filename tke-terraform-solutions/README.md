# TKE Terraform 解决方案

## 概述

本指南提供了使用 Terraform 管理 TKE 集群、原生节点和超级节点的完整解决方案。通过本指南，您可以学习如何使用 Terraform 实现 Kubernetes 集群资源的全生命周期管理。

## 解决方案目录

| 方案 | 描述 |
|------|------|
| [solution-1: 创建 TKE 集群](./solution-1) | 使用 Terraform 创建 TKE 集群 |
| [solution-2: 创建 TKE 原生节点集群](./solution-2) | 使用 Terraform 创建完整的 TKE 集群并添加原生节点池 |
| [solution-3: 创建 TKE 超级节点集群](./solution-3) | 使用 Terraform 创建完整的 TKE 集群并添加超级节点 |

## 准备工作

1. 安装 Terraform (推荐版本 1.0+)
2. 获取腾讯云访问密钥 (SecretId 和 SecretKey)
3. 配置腾讯云凭证：
   ```bash
   export TENCENTCLOUD_SECRET_ID=your_secret_id
   export TENCENTCLOUD_SECRET_KEY=your_secret_key
   export TENCENTCLOUD_REGION=your_region  # 例如 ap-beijing
   ```

## 使用方法

1. 选择适合您需求的解决方案目录
2. 进入对应目录并初始化 Terraform:
   ```bash
   cd solution-X
   terraform init
   ```
3. 查看执行计划:
   ```bash
   terraform plan
   ```
4. 应用配置:
   ```bash
   terraform apply
   ```
5. 清理资源 (可选):
   ```bash
   terraform destroy
   ```

## 注意事项

1. 在生产环境中使用前，请仔细阅读各方案的详细说明
2. 某些字段为 forcenew 属性，修改会导致资源重建
3. 建议启用 Terraform 日志以便调试:
   ```bash
   export TF_LOG=DEBUG
   export TF_LOG_PATH=./terraform.log
   ```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进本指南。
