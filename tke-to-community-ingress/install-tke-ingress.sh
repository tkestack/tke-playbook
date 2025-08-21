#!/bin/bash

# 一键部署 TKE Nginx Ingress 和 demo 应用

set -e  # 遇到错误时退出

echo "开始部署 TKE Nginx Ingress 和 demo 应用..."

# 第一步：部署 TKE Nginx Ingress
echo "开始部署 TKE Nginx Ingress..."
kubectl apply -f tke-NginxIngress.yaml
echo "部署 TKE Nginx Ingress 成功"

# 第二步：验证 TKE Nginx Ingress 是否创建
echo "验证 TKE Nginx Ingress 是否创建..."

echo "检查 ingressclass:"
kubectl get ingressclass

# 第三步：创建 Demo

# 1. 创建 nginx-demo deployment 和 service
echo "创建 nginx-demo deployment 和 service..."
kubectl apply -f nginx-deploy-svc.yaml
echo "nginx-demo deployment 和 service 创建完成"

# 2. 创建 TKE Nginx Ingress 对应的Ingress
echo "创建 TKE Nginx Ingress 对应的Ingress..."
kubectl apply -f nginx-demo-ingress.yaml
echo "nginx-demo-ingress 创建完成"

echo "部署完成！即将进行访问测试"
while true; do date '+%F %T'; curl -s -o /dev/null -w '%{http_code} %{time_total}\n' a.com; sleep 1; done
echo "访问测试通过"
