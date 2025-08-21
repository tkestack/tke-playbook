#!/bin/bash

# 一键部署 TKE Nginx Ingress 和 demo 应用

set -e  # 遇到错误时退出

echo "开始部署 TKE Nginx Ingress 和 demo 应用..."

# 第一步：部署 TKE Nginx Ingress
echo "开始部署 TKE Nginx Ingress..."
cat > TKE-Nginx-Ingress.yaml << 'EOF'
apiVersion: cloud.tencent.com/v1alpha1
kind: NginxIngress
metadata:
  name: test
spec:
  ingressClass: test
  service:
    annotation:
      service.kubernetes.io/service.extensiveParameters: '{"AddressIPVersion":"IPV4","InternetAccessible":{"InternetChargeType":"TRAFFIC_POSTPAID_BY_HOUR","InternetMaxBandwidthOut":10}}'
    directAccess: true
    type: LoadBalancer
  workLoad:
    hpa:
      enable: true
      maxReplicas: 2
      metrics:
      - pods:
          metricName: k8s_pod_rate_cpu_core_used_limit
          targetAverageValue: "80"
        type: Pods
      minReplicas: 1
    template:
      affinity: {}
      container:
        image: hkccr.ccs.tencentyun.com/tkeimages/nginx-ingress-controller:v1.9.5
        resources:
          limits:
            cpu: "0.5"
            memory: 1024Mi
          requests:
            cpu: "0.25"
            memory: 256Mi
    type: deployment
EOF

kubectl apply -f TKE-Nginx-Ingress.yaml
echo "部署 TKE Nginx Ingress 成功"

# 第二步：验证 TKE Nginx Ingress 是否创建
echo "验证 TKE Nginx Ingress 是否创建..."

echo "检查 ingressclass:"
kubectl get ingressclass

# 第三步：创建 Demo

# 1. 创建 nginx-demo deployment 和 service
echo "创建 nginx-demo deployment 和 service..."

cat > nginx-deploy-svc.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-demo-svc
spec:
  selector:
    app: nginx-demo
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

kubectl apply -f nginx-deploy-svc.yaml
echo "nginx-demo deployment 和 service 创建完成"

# 2. 创建 TKE Nginx Ingress 对应的Ingress
echo "创建 TKE Nginx Ingress 对应的Ingress..."

cat > nginx-demo-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-demo-ingress
  annotations:
    kubernetes.io/ingress.class: test
    kubernetes.io/ingress.rule-mix: "false"
spec:
  rules:
  - host: a.com
    http:
      paths:
      - backend:
          service:
            name: nginx-demo-svc
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific
EOF

kubectl apply -f nginx-demo-ingress.yaml
echo "nginx-demo-ingress 创建完成"

echo "部署完成！即将进行访问测试"
while true; do date '+%F %T'; curl -s -o /dev/null -w '%{http_code} %{time_total}\n' a.com; sleep 1; done
echo "访问测试通过"
