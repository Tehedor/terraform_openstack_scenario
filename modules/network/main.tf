// Módulo: network
// Propósito: crear una red y su subred asociada en OpenStack.

terraform {
  # Aquí se declaran los proveedores requeridos para este módulo.
  # `openstack` es el proveedor que permite a Terraform interactuar con
  # una nube OpenStack (crear redes, subredes, instancias, etc.).
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0" # Restringe la versión del proveedor a la serie 1.53.x
    }
  }
}

// Recurso: openstack_networking_network_v2.net
// Qué hace: crea una red L2 en OpenStack (equivalente a un tenant network/neutron network).
// Uso: otras entidades (como subredes, routers o instancias) referencian esta red
// mediante su id: `openstack_networking_network_v2.net.id`.
resource "openstack_networking_network_v2" "net" {
  name           = var.network_name
  admin_state_up = "true"
}

// Recurso: openstack_networking_subnet_v2.subnet
// Qué hace: crea una subred IPv4 asociada a la red creada arriba.
// Detalles importantes:
// - `network_id` enlaza la subred con la red creada (`net`).
// - `cidr` define el rango de direcciones IP de la subred (ej. 10.1.2.0/24).
// - `gateway_ip` especifica la puerta de enlace dentro del CIDR.
// - `allocation_pool` restringe el rango de IPs que se otorgarán dinámicamente.
resource "openstack_networking_subnet_v2" "subnet" {
  name            = var.subnet_name
  network_id      = openstack_networking_network_v2.net.id
  cidr            = var.cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8"]

  gateway_ip = cidrhost(var.cidr, 1)

  allocation_pool {
    start = cidrhost(var.cidr, 2)   # Ej: 10.1.2.2
    end   = cidrhost(var.cidr, 100) # Ej: 10.1.2.100 (ajustable según necesidades)
  }
}