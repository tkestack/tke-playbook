# 创建VPC
resource "tencentcloud_vpc" "this" {
  name         = var.vpc_name
  cidr_block   = var.vpc_cidr
}

# 创建子网
resource "tencentcloud_subnet" "this" {
  name              = var.subnet_name
  vpc_id            = tencentcloud_vpc.this.id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr
}

# 安全组
resource "tencentcloud_security_group" "this" {
  name        = "terraform-security-group"
  description = "Security group for TKE cluster created by Terraform"
  project_id  = 0
}

# 安全组规则集
resource "tencentcloud_security_group_rule_set" "rules" {
  security_group_id = tencentcloud_security_group.this.id

  # 允许SSH访问
  ingress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "TCP"
    port        = "22"
    description = "SSH Access"
  }

  # 允许ICMP
  ingress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "ICMP"
    description = "ICMP Access"
  }

  # 允许API Server访问
  ingress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "TCP"
    port        = "6443"
    description = "Kubernetes API Access"
  }

  # 允许VPC内部通信
  ingress {
    action      = "ACCEPT"
    cidr_block  = var.vpc_cidr
    protocol    = "ALL"
    description = "Node-to-Node Communication"
  }

  # 允许所有出站流量
  egress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "ALL"
    description = "All Outbound"
  }
}

# 创建TKE集群（无工作节点）
resource "tencentcloud_kubernetes_cluster" "this" {
  vpc_id                     = tencentcloud_vpc.this.id
  service_cidr               = var.service_cidr
  cluster_max_pod_num        = 256
  cluster_name               = var.cluster_name
  cluster_desc               = "TKE cluster with super nodes created by Terraform"
  cluster_max_service_num    = 1024
  cluster_version            = var.cluster_version
  cluster_level              = "L5"
  auto_upgrade_cluster_level = true
  network_type               = "VPC-CNI"
  eni_subnet_ids             = [tencentcloud_subnet.this.id]
}

# 配置集群端点（内网访问）
resource "tencentcloud_kubernetes_cluster_endpoint" "cluster_endpoint" {
  cluster_id              = tencentcloud_kubernetes_cluster.this.id
  cluster_intranet        = true
  cluster_intranet_subnet_id = tencentcloud_subnet.this.id
  
  depends_on = [
    tencentcloud_kubernetes_cluster.this,
    tencentcloud_kubernetes_serverless_node_pool.this
  ]
}

# 创建TKE超级节点
resource "tencentcloud_kubernetes_serverless_node_pool" "this" {
  cluster_id = tencentcloud_kubernetes_cluster.this.id
  name       = var.super_node_name
  security_group_ids = [tencentcloud_security_group.this.id]
  
  # 超级节点
  serverless_nodes {
    display_name = "super-node"
    subnet_id    = tencentcloud_subnet.this.id
  }
  
  labels = {
    "super-node" : "true"
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
