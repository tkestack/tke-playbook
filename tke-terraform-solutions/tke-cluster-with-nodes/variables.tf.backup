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

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "172.18.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes版本"
  default     = "1.32.2"
}

variable "service_cidr" {
  description = "Kubernetes服务CIDR"
  default     = "10.200.0.0/22"
}

variable "instance_type" {
  description = "实例类型"
  default     = "S5.MEDIUM4"
}

variable "cluster_name" {
  description = "TKE集群名称"
  default     = "terraform-test-cluster"
}

variable "vpc_name" {
  description = "VPC名称"
  default     = "terraform-test-vpc"
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
