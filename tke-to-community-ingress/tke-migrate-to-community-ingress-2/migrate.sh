echo "11. 获取新的 Ingress Nginx 的 External IP..."
new_external_ip=$(kubectl get svc -n ingress-nginx new-test-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "新的 Ingress Nginx External IP: $new_external_ip"

echo "迁移完成！即将进行访问测试"
echo "直接通过 IP 地址访问服务以避免修改系统 DNS 配置"
while true; do date '+%F %T'; curl -s -H "Host: $host" http://$new_external_ip -o /dev/null -w '%{http_code} %{time_total}\n'; sleep 1; done
echo "访问测试通过"
