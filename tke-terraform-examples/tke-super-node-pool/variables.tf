variable "region" {
  description = "区域"
  default     = "ap-singapore"
}

variable "tencentcloud_secret_id" {
  description = "腾讯云SecretId"
  type        = string
  sensitive   = true
}

variable "tencentcloud_secret_key" {
  description = "腾讯云SecretKey"
  type        = string
  sensitive   = true
}

variable "vpc_name" {
  description = "VPC名称"
  default     = "terraform-super-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "172.18.0.0/16"
}

variable "subnet_name" {
  description = "子网名称"
  default     = "terraform-super-subnet"
}

variable "availability_zone" {
  description = "可用区"
  default     = "ap-singapore-1"
}

variable "subnet_cidr" {
  description = "子网CIDR"
  default     = "172.18.100.0/24"
}

variable "cluster_name" {
  description = "TKE集群名称"
  default     = "terraform-super-cluster"
}

variable "cluster_version" {
  description = "Kubernetes版本"
  default     = "1.32.2"
}

variable "service_cidr" {
  description = "Kubernetes服务CIDR"
  default     = "10.203.0.0/22"
}

variable "cluster_id" {
  description = "TKE集群ID"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "子网ID"
  type        = string
  default     = ""
}

variable "super_node_name" {
  description = "超级节点名称"
  default     = "terraform-super-node"
}

variable "instance_type" {
  description = "实例类型"
  default     = "SA5.MEDIUM4"
}

variable "system_disk_size" {
  description = "系统磁盘大小（GB）"
  default     = 60
}

variable "subnets" {
  description = "子网配置"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "primary" = {
      cidr = "172.18.100.0/24"
      az   = "ap-singapore-1"
    }
    "secondary" = {
      cidr = "172.18.101.0/24"
      az   = "ap-singapore-2"
    }
  }
}
