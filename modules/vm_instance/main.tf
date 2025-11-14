terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}
# ---------------------------------------------------------
# 0. RECURSO DE KEYPAIRS
# # ---------------------------------------------------------
# resource "openstack_compute_keypair_v2" "key"{
#   name            = var.key_pair
#   # public_key = file()
# }

resource "openstack_compute_keypair_v2" "key" {
  count = var.create_keypair ? 1 : 0
  # Si se pasa key_pair como nombre lo usamos; si no, generamos "<name>-key"
  name  = var.key_pair != "" ? var.key_pair : "${var.name}-key"
}


# ---------------------------------------------------------
# 1. RECURSO DE MÁQUINA VIRTUAL
# ---------------------------------------------------------
resource "openstack_compute_instance_v2" "vm" {
  name            = var.name
  image_name      = var.image
  flavor_name     = var.flavor
  security_groups = var.security_groups

  # key_pair        = openstack_compute_keypair_v2.
  # key_pair = var.key_pair != "" ? var.key_pair : null
  # key_pair = var.key_pair != "" ? var.key_pair : null
  key_pair = (var.create_keypair ? openstack_compute_keypair_v2.key[0].name : (var.key_pair != "" ? var.key_pair : null))
 

  # INYECCIÓN DINÁMICA DE CLOUD-INIT
  # La función file() lee el contenido del script yaml pasado por la variable user_data_file

  # Conexión a la red interna (la ID viene como variable de entrada)
  network {
    uuid = var.network_id
  }

  #Añade la segunda red dinámicamente solo si es necesario
  dynamic "network" {
    for_each = var.asign_multiple_network ? [var.second_network_id] : []
    content {
      uuid = network.value
    }
  }

  # User data con plantilla condicional

  user_data = var.user_data_file != "" ? templatefile(var.user_data_file, {
    page_title          = var.name != null ? var.name : ""
    db_host             = var.db_host != null ? var.db_host : ""
    db_user             = var.db_user != null ? var.db_user : ""
    db_pass             = var.db_pass != null ? var.db_pass : ""
    db_name             = var.db_name != null ? var.db_name : ""
    object_storage_host = var.object_storage_host != null ? var.object_storage_host : ""
  }) : null
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
  # port_id     = openstack_compute_instance_v2.vm.network[0].port
}


