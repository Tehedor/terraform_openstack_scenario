terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

data "openstack_networking_network_v2" "ext_network" {
  name = var.ext_network
}

resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  external_network_id = data.openstack_networking_network_v2.ext_network.id
}

resource "openstack_networking_port_v2" "router_port" {
  network_id = var.network_id
  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = var.gateway
  }
}

resource "openstack_networking_router_interface_v2" "net1" {
  router_id = openstack_networking_router_v2.router.id
  port_id   = openstack_networking_port_v2.router_port.id
}