terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

resource "openstack_networking_network_v2" "net" {
  name           = var.network_name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = var.subnet_name
  network_id = openstack_networking_network_v2.net.id
  cidr       = var.cidr
  ip_version = 4

  dns_nameservers = var.has_internet ? ["8.8.8.8", "1.1.1.1"] : []

  gateway_ip = var.has_internet ? cidrhost(var.cidr, 1) : null

  allocation_pool {
    start = cidrhost(var.cidr, 2)
    end   = cidrhost(var.cidr, 100)
  }
}
