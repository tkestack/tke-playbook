#!/bin/bash

# TKE Nginx Ingress 迁移一键启动脚本

set -e  # 遇到错误时退出

echo "开始 TKE Nginx Ingress 迁移准备工作..."

# 前置条件：安装 Helm 并添加仓库
echo "1. 安装 Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "2. 添加 ingress-nginx 官方 Helm 仓库..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# 方案一实施步骤
echo "3. 确认已安装的 Nginx Ingress 相关信息..."

echo "3.1 查找 Nginx Ingress Deployment..."
kubectl get deploy -A | grep nginx

echo "3.2 获取 TKE Nginx Ingress 镜像版本..."
image_version=$(kubectl get deploy -n kube-system test-ingress-nginx-controller -o yaml | grep image: | grep nginx-ingress-controller | sed -E 's/.*nginx-ingress-controller:(v?[0-9]+\.[0-9]+\.[0-9]+).*/\1/' | head -1)
echo "检测到镜像版本: $image_version"

# 移除版本号前的 "v" 前缀（如果存在）
clean_version=$(echo "$image_version" | sed 's/^v//')
echo "清理后的版本号: $clean_version"

echo "4. 确认当前使用的 Chart 版本..."
chart_version=$(helm search repo ingress-nginx/ingress-nginx --versions | grep $clean_version | awk '{print $2}' | head -1)
echo "检测到 Chart 版本: $chart_version"

# 如果未找到 chart 版本，使用默认值
if [ -z "$chart_version" ]; then
  chart_version="4.9.0"
  echo "未找到匹配的 Chart 版本，默认使用: $chart_version"
fi

# 创建 values.yaml 配置文件
echo "5. 配置 values.yaml..."
cat > values.yaml << 'EOF'
controller:
  ingressClass: new-test # 新 IngressClass 名称，避免冲突
  ingressClassResource:
    name: new-test
    enabled: true
    controllerValue: k8s.io/new-test
EOF

echo "6. 安装新的 Nginx Ingress Controller..."
helm upgrade --install new-test-ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version $chart_version \
  -f values.yaml

echo "7. 获取新 Nginx Ingress 的流量入口..."
kubectl -n ingress-nginx get svc
# 创建新的 Ingress 资源
echo "8. 复制并修改 Ingress 配置..."

# 检查是否存在 nginx-demo-ingress.yaml 文件
if [ ! -f "nginx-demo-ingress.yaml" ]; then
  echo "错误: nginx-demo-ingress.yaml 文件不存在"
  exit 1
fi

# 复制并修改 Ingress 配置文件
cp nginx-demo-ingress.yaml new-nginx-demo-ingress.yaml

# 修改 IngressClass 为 new-test
sed -i 's/kubernetes.io\/ingress.class: test/kubernetes.io\/ingress.class: new-test/' new-nginx-demo-ingress.yaml

# 修改 Ingress 名称
sed -i 's/name: nginx-demo-ingress/name: new-nginx-demo-ingress/' new-nginx-demo-ingress.yaml

# 应用新创建的 Ingress 配置文件
kubectl apply -f new-nginx-demo-ingress.yaml

echo "9. 验证新旧 Ingress..."
kubectl get ingress nginx-demo-ingress
kubectl get ingress new-nginx-demo-ingress

echo "10. 测试访问5秒..."
# 获取新 Ingress 的外部 IP
new_external_ip=$(kubectl get svc -n ingress-nginx new-test-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
host=$(kubectl get ingress nginx-demo-ingress -o jsonpath='{.spec.rules[0].host}')

echo "测试新 Ingress 的访问..."
for i in {1..5}; do
  curl -s -w "%{http_code} %{time_total}\n" -o /dev/null -H "Host: $host" http://$new_external_ip
  sleep 1
done
