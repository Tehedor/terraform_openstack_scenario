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
  name            = var.subnet_name
  network_id      = openstack_networking_network_v2.net.id # Referencia a la red creada arriba
  cidr            = var.cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8"]

  gateway_ip = cidrhost(var.cidr, 1) # Ej: 10.1.2.1

  allocation_pool {
    start = cidrhost(var.cidr, 2)   # Ej: 10.1.2.2
    end   = cidrhost(var.cidr, 100) # Ej: 10.1.2.100 (ajustable)
  }
}