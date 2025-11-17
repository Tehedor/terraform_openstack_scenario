terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

resource "openstack_compute_keypair_v2" "key" {
  count = var.create_keypair ? 1 : 0
  name = var.key_pair != "" ? var.key_pair : "${var.name}-key"
}


resource "openstack_compute_instance_v2" "vm" {
  name            = var.name
  image_name      = var.image
  flavor_name     = var.flavor
  security_groups = var.security_groups

  key_pair = (var.create_keypair ? openstack_compute_keypair_v2.key[0].name : (var.key_pair != "" ? var.key_pair : null))

  network {
    uuid = var.network_id
  }

  dynamic "network" {
    for_each = var.asign_multiple_network ? [var.second_network_id] : []
    content {
      uuid = network.value
    }
  }

  user_data = var.user_data_file != "" ? templatefile(var.user_data_file, {
    page_title          = var.name != null ? var.name : ""
    db_host             = var.db_host != null ? var.db_host : ""
    db_user             = var.db_user != null ? var.db_user : ""
    db_pass             = var.db_pass != null ? var.db_pass : ""
    db_name             = var.db_name != null ? var.db_name : ""
    object_storage_host = var.object_storage_host != null ? var.object_storage_host : ""
  }) : null
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = var.assign_floating_ip ? 1 : 0
  pool  = "ExtNet" 
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  count       = var.assign_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  instance_id = openstack_compute_instance_v2.vm.id
}


