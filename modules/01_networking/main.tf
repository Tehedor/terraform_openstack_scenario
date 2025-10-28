# network 1
resource "openstack_networking_network_v2" "net1" {
  name = var.nombre_red
}

# subnetwork 1
resource "openstack_networking_subnet_v2" "subnet1" {
  name            = var.nombre_subred
  network_id      = openstack_networking_network_v2.net1.id
  cidr            = "10.1.2.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8"]
  gateway_ip      = "10.1.2.1"
  allocation_pool {
    start = "10.1.2.2"
    end   = "10.1.2.100"
  }
}

# network 2
resource "openstack_networking_network_v2" "net2" {
  name = var.nombre_red2
}
# subnetwork 2
resource "openstack_networking_subnet_v2" "subnet2" {
  name            = var.nombre_subred2
  network_id      = openstack_networking_network_v2.net2.id
  cidr            = "10.1.3.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8"]
  gateway_ip      = "10.1.3.1"
  allocation_pool {
    start = "10.1.3.2"
    end   = "10.1.3.100"
  }
}