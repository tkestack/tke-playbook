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

# 创建TKE集群
resource "tencentcloud_kubernetes_cluster" "this" {
  vpc_id                                     = tencentcloud_vpc.this.id
  cluster_cidr                               = var.service_cidr
  cluster_max_pod_num                        = 32
  cluster_name                               = var.cluster_name
  cluster_desc                               = "TKE cluster created by Terraform"
  cluster_max_service_num                    = 32
  cluster_version                            = var.cluster_version
  cluster_os                                 = "tlinux2.2(tkernel3)x86_64"
  cluster_level                              = "L5"
  auto_upgrade_cluster_level                 = true
  network_type                               = "GR"
  cluster_internet                           = false
  cluster_intranet                           = false
}

# 创建普通节点池
resource "tencentcloud_kubernetes_node_pool" "this" {
  name                    = "default-node-pool"
  cluster_id              = tencentcloud_kubernetes_cluster.this.id
  max_size                = 6
  min_size                = 1
  desired_capacity        = 1
  enable_auto_scale       = true
  delete_keep_instance    = false
  node_os                 = "tlinux2.2(tkernel3)x86_64"
  vpc_id                  = tencentcloud_vpc.this.id
  subnet_ids              = [tencentcloud_subnet.this.id]
  
  auto_scaling_config {
    instance_type              = var.instance_type
    system_disk_type           = "CLOUD_SSD"
    system_disk_size           = 60
    orderly_security_group_ids = [tencentcloud_security_group.this.id]
    password                   = "Qcloud@123"
    
    data_disk {
      disk_type = "CLOUD_SSD"
      disk_size = 50
    }
  }
  
  labels = {
    "node-type" = "regular"
  }
  
  taints {
    key    = "special"
    value  = "true"
    effect = "NoSchedule"
  }
}

# 输出集群访问信息
output "kubeconfig" {
  value = tencentcloud_kubernetes_cluster.this.kube_config
  sensitive = true
}

output "cluster_id" {
  value = tencentcloud_kubernetes_cluster.this.id
}

# 输出节点池信息
output "node_pool_id" {
  value = tencentcloud_kubernetes_node_pool.this.id
}
