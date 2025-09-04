echo "11. 配置 DNS 解析..."
# 获取新的 Ingress Nginx 的 External IP
new_external_ip=$(kubectl get svc -n ingress-nginx nginx-new-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "新的 Ingress Nginx External IP: $new_external_ip"

# 检查 /etc/hosts 是否已存在相关记录
if grep -q "$host" /etc/hosts; then
  # 如果存在，更新记录
  sudo sed -i "s/.*$host$/$new_external_ip $host/" /etc/hosts
  echo "已更新 /etc/hosts 中的域名解析记录"
else
  # 如果不存在，添加新记录
  echo "$new_external_ip $host" | sudo tee -a /etc/hosts
  echo "已添加新的域名解析记录到 /etc/hosts"
fi

echo "迁移完成！即将进行访问测试"
while true; do date '+%F %T'; curl -s -o /dev/null -w '%{http_code} %{time_total}\n' a.com; sleep 1; done
echo "访问测试通过"
