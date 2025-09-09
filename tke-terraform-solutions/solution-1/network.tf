# 创建VPC
resource "tencentcloud_vpc" "this" {
  name         = var.vpc_name
  cidr_block   = var.vpc_cidr
  dns_servers  = ["8.8.8.8", "114.114.114.114"]
  is_multicast = false
}

# 创建子网
resource "tencentcloud_subnet" "this" {
  name              = "terraform-test-subnet"
  vpc_id            = tencentcloud_vpc.this.id
  availability_zone = var.subnets["primary"]["az"]
  cidr_block        = var.subnets["primary"]["cidr"]
  is_multicast      = false
}
