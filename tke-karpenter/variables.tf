variable "region" {
  description = "region"
  default     = "ap-singapore"
}
variable "tencentcloud_secret_id" {
  description = "SecretId"
  type        = string
  sensitive   = true
}

variable "tencentcloud_secret_key" {
  description = "SecretKey"
  type        = string
  sensitive   = true
}
variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "172.18.0.0/16"
}

variable "subnets" {
  description = "subnets"
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

variable "cluster_version" {
  description = "Kubernetes version"
  default     = "1.32.2"
}

variable "service_cidr" {
  description = "Kubernetes CIDR"
  default     = "10.200.0.0/22"
}

variable "instance_type" {
  description = "Instance type for worker nodes"
  default     = "SA5.MEDIUM4"
}
variable "image_tag" {
  description = "Image tag for containers"
  default     = "latest"
}
variable "cluster_id" {
  description = "TKE cluster id"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key for node access"
  type        = string
  default     = ""
}
