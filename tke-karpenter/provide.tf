# Use Tencent Cloud Terraform Provider with version >= 1.82.11.
terraform {
  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
      version = "~> 1.82.11"
    }
  }
}

provider "tencentcloud" {
  region = var.region
  secret_id  = var.tencentcloud_secret_id
  secret_key = var.tencentcloud_secret_key
}
