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
  cluster_desc               = "TKE cluster with native nodes created by Terraform"
  cluster_max_service_num    = 32
  cluster_version            = var.cluster_version
  cluster_os                 = "tlinux2.2(tkernel3)x86_64"
  cluster_level              = "L5"
  auto_upgrade_cluster_level = true
  network_type               = "GR"
  cluster_internet           = false
  cluster_intranet           = false
}

# 创建TKE原生节点池
resource "tencentcloud_kubernetes_native_node_pool" "kubernetes_native_node_pool" {
  name                = var.nodepool_name
  cluster_id          = tencentcloud_kubernetes_cluster.this.id
  type                = "Native"
  unschedulable       = false
  deletion_protection = true
  labels {
    name  = "workload-type"
    value = "stable"
  }

  native {
    instance_charge_type = "POSTPAID_BY_HOUR"
    instance_types       = [var.instance_type]
    security_group_ids   = [tencentcloud_security_group.this.id]
    subnet_ids           = [tencentcloud_subnet.this.id]
    
    replicas             = var.node_count
    machine_type         = "Native"
    
    scaling {
      min_replicas  = var.node_count
      max_replicas  = 10
      create_policy = "ZoneEquality"
    }
    
    system_disk {
      disk_type = "CLOUD_SSD"
      disk_size = 100
    }

    data_disks {
      auto_format_and_mount = true
      disk_type             = "CLOUD_SSD"
      disk_size             = 100
      file_system           = "ext4"
      mount_target          = "/var/lib/container"
    }
    
    # 移除可能导致问题的复杂配置
    # auto_repair              = true
    # health_check_policy_name = null
    # enable_autoscaling = false
    # host_name_pattern  = null
    # management {
    #   nameservers = ["183.60.83.19", "183.60.82.98"]
    #   kernel_args = ["kernel.pid_max=65535", "fs.file-max=400000"]
    # }
    # kubelet_args = ["allowed-unsafe-sysctls=net.core.somaxconn"]
    # lifecycle {
    #   pre_init  = "ZWNobyBoZWxsb3dvcmxk"
    #   post_init = "ZWNobyBoZWxsb3dvcmxk"
    # }
    # runtime_root_dir = "/var/lib/containerd"
  }
  
  lifecycle {
    ignore_changes = [
      native[0].instance_types,
      native[0].system_disk
    ]
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

output "nodepool_id" {
  value = tencentcloud_kubernetes_native_node_pool.kubernetes_native_node_pool.id
}
