resource "tencentcloud_kubernetes_cluster" "tke_cluster" {
  cluster_name        = "tke-${random_string.suffix.result}(auto-scaler-test)"
  cluster_desc        = "Kubernetes cluster"
  cluster_version     = var.cluster_version
  container_runtime   = "containerd"
  vpc_id              = tencentcloud_vpc.main.id
  service_cidr        = var.service_cidr
  cluster_max_service_num = 1024
  cluster_max_pod_num = 256
  cluster_deploy_type = "MANAGED_CLUSTER"
  auto_upgrade_cluster_level = true

  # disable ca 
  # node_pool_global_config {
  #  is_scale_in_enabled     = false
  #}

  # enable karpenter
  extension_addon {
    name    = "karpenter"
    param   = jsonencode({
      "enable" = true
    })
  }

  is_non_static_ip_mode = false

  network_type         = "VPC-CNI"

  eni_subnet_ids       = [
    tencentcloud_subnet.subnets["primary"].id,
    tencentcloud_subnet.subnets["secondary"].id
  ]
  
  tags = {
    ha     = "multi-az"
  }
  depends_on = [
    tencentcloud_vpc.main
  ]
  
}

# create native node for enabling  apiserver intranet access
resource "tencentcloud_kubernetes_native_node_pool" "native_nodepool-1"  {
  name                = "native_nodepool-1"
  cluster_id          = tencentcloud_kubernetes_cluster.tke_cluster.id
  type                = "Native"
  unschedulable       = false
  
  labels {
    name  = "workload-type"
    value = "stable"
  }

  native {
    instance_charge_type = "POSTPAID_BY_HOUR"
    instance_types       = [var.instance_type]
    security_group_ids   = [tencentcloud_security_group.main.id]
    subnet_ids           = [tencentcloud_subnet.subnets["primary"].id, tencentcloud_subnet.subnets["secondary"].id] 
    replicas             = 2  
    machine_type         = "Native"
    
    scaling {
      min_replicas  = 2
      max_replicas  = 6
      create_policy = "ZoneEquality" 
    }
    
    system_disk {
      disk_type = "CLOUD_BSSD"
      disk_size = 100
    }

    data_disks {
      auto_format_and_mount = true
      disk_type             = "CLOUD_BSSD"
      disk_size             = 100
      file_system           = "ext4"
      mount_target          = "/var/lib/container"
    }
  }
  lifecycle {
    ignore_changes = [
      native[0].instance_types, 
      native[0].system_disk    
    ]
  }
   tags {
    resource_type = "native_node"
  }
  depends_on = [
    tencentcloud_kubernetes_cluster.tke_cluster
  ]
}




# enable intranet
resource "tencentcloud_kubernetes_cluster_endpoint" "cluster_endpoint" {
  cluster_id              = tencentcloud_kubernetes_cluster.tke_cluster.id
  cluster_intranet        = true
  cluster_intranet_subnet_id = tencentcloud_subnet.subnets["primary"].id
  
  
  depends_on = [
    tencentcloud_kubernetes_native_node_pool.native_nodepool-1
  ]
}

#  generate kubeconfig 
resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig.yaml"
  content  = tencentcloud_kubernetes_cluster_endpoint.cluster_endpoint.kube_config_intranet
  
  provisioner "local-exec" {
    command = "sed -i '' $'s/\r//g' ${path.module}/kubeconfig.yaml"
  }
  depends_on = [tencentcloud_kubernetes_cluster_endpoint.cluster_endpoint]
}


output "cluster_id" {
  value = tencentcloud_kubernetes_cluster.tke_cluster.id
}

output "kubeconfig" {
  value     = local_file.kubeconfig.filename
  sensitive = true
}
