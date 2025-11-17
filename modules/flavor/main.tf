terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

resource "openstack_compute_flavor_v2" "custom_flavor" {
  name      = var.name
  ram       = var.ram 
  vcpus     = var.vcpus
  disk      = var.disk
  swap      = var.swap 
  ephemeral = var.ephemeral
  is_public = var.is_public

  extra_specs = var.extra_specs
}
