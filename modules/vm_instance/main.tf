terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}
# ---------------------------------------------------------
# 1. RECURSO DE MÁQUINA VIRTUAL
# ---------------------------------------------------------
resource "openstack_compute_instance_v2" "vm" {
  name            = var.name
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = var.key_pair
  security_groups = var.security_group_ids

  # Conexión a la red interna (la ID viene como variable de entrada)
  network {
    uuid = var.network_id
  }

  # INYECCIÓN DINÁMICA DE CLOUD-INIT
  # La función file() lee el contenido del script yaml pasado por la variable user_data_file
  user_data = file(var.user_data_file)
}

# ---------------------------------------------------------
# 2. LÓGICA DE IP FLOTANTE (CONDICIONAL)
# ---------------------------------------------------------

# Count = 1 si la variable 'assign_floating_ip' es true, 0 si es false.
# Esto asegura que el recurso solo se cree si es necesario (ADMIN/LB).
resource "openstack_networking_floatingip_v2" "fip" {
  count = var.assign_floating_ip ? 1 : 0
  pool  = "ExtNet" # Pool por defecto de OpenStack/VNX
}

# Asocia la Floating IP a la instancia
resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  count       = var.assign_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  instance_id = openstack_compute_instance_v2.vm.id
}