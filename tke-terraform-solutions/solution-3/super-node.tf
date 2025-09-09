# 创建VPC
resource "tencentcloud_vpc" "this" {
  name         = var.vpc_name
  cidr_block   = var.vpc_cidr
  dns_servers  = ["8.8.8.8", "114.114.114.114"]
  is_multicast = false
}

# 创建子网
resource "tencentcloud_subnet" "this" {
  name              = var.subnet_name
  vpc_id            = tencentcloud_vpc.this.id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr
  is_multicast      = false
}

# 创建安全组
resource "tencentcloud_security_group" "this" {
  name        = "terraform-security-group"
  description = "Security group for TKE cluster created by Terraform"
  project_id  = 0
}

# 创建安全组规则 - 允许SSH访问
resource "tencentcloud_security_group_rule" "ssh" {
  security_group_id = tencentcloud_security_group.this.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "22"
  policy            = "accept"
}

# 创建安全组规则 - 允许ICMP
resource "tencentcloud_security_group_rule" "icmp" {
  security_group_id = tencentcloud_security_group.this.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "icmp"
  policy            = "accept"
}

# 创建TKE集群（无工作节点）
resource "tencentcloud_kubernetes_cluster" "this" {
  vpc_id                     = tencentcloud_vpc.this.id
  cluster_cidr               = var.service_cidr
  cluster_max_pod_num        = 32
  cluster_name               = var.cluster_name
  cluster_desc               = "TKE cluster with super nodes created by Terraform"
  cluster_max_service_num    = 32
  cluster_version            = var.cluster_version
  cluster_os                 = "tlinux2.2(tkernel3)x86_64"
  cluster_level              = "L5"
  auto_upgrade_cluster_level = true
  network_type               = "GR"
  cluster_internet           = false
  cluster_intranet           = false
}

# 创建TKE超级节点
resource "tencentcloud_kubernetes_serverless_node_pool" "this" {
  cluster_id = tencentcloud_kubernetes_cluster.this.id
  name       = var.super_node_name
  security_group_ids = [tencentcloud_security_group.this.id]
  
  # 主可用区节点
  serverless_nodes {
    display_name = "super-node-1"
    subnet_id    = tencentcloud_subnet.this.id
  }
  
  # 备用可用区节点
  serverless_nodes {
    display_name = "super-node-2"
    subnet_id    = tencentcloud_subnet.this.id
  }
  
  labels = {
    "super-node" : "true"
  }
  
  taints {
    key    = "super-node"
    value  = "true"
    effect = "NoSchedule"
  }
}

# 输出集群访问信息
output "kubeconfig" {
  value     = tencentcloud_kubernetes_cluster.this.kube_config
  sensitive = true
}

output "cluster_id" {
  value = tencentcloud_kubernetes_cluster.this.id
}

# 输出超级节点信息
output "super_node_id" {
  value = tencentcloud_kubernetes_serverless_node_pool.this.id
}

output "super_node_status" {
  value = tencentcloud_kubernetes_serverless_node_pool.this.life_state
}
