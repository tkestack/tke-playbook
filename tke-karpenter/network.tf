resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# create VPC
resource "tencentcloud_vpc" "main" {
  name       = "vpc-${random_string.suffix.result}"
  cidr_block = var.vpc_cidr
}

#  
resource "tencentcloud_subnet" "subnets" {
  for_each = var.subnets

  name              = "subnet-${each.key}-${random_string.suffix.result}"
  vpc_id            = tencentcloud_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    az   = "az-${each.value.az}"
  }
  depends_on = [
    tencentcloud_vpc.main
  ]
}


# security_group
resource "tencentcloud_security_group" "main" {
  name        = "sg-${random_string.suffix.result}"
  description = "security_group_for_tke"
}


resource "tencentcloud_security_group_rule_set" "rules" {
  security_group_id = tencentcloud_security_group.main.id

  ingress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "TCP"
    port        = "22"
    description = "SSH Access"
  }
  # allow apiserver access
  ingress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "TCP"
    port        = "6443"
    description = "Kubernetes API Access"
  }

  # allow vpc cidr access 
  ingress {
    action      = "ACCEPT"
    cidr_block  = var.vpc_cidr
    protocol    = "ALL"
    description = "Node-to-Node Communication"
  }
  egress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "ALL"
    description = "All Outbound"
  }

}
output "vpc_id" {
  value = tencentcloud_vpc.main.id
}

output "subnet_primary_id" {
  value = tencentcloud_subnet.subnets["primary"].id
}

output "subnet_secondary_id" {
  value = tencentcloud_subnet.subnets["secondary"].id
}

output "security_group_id" {
  value = tencentcloud_security_group.main.id
}