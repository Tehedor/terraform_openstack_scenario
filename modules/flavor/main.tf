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
  ram       = var.ram # en MB
  vcpus     = var.vcpus
  disk      = var.disk # disco raíz en GB
  swap      = var.swap # swap en MB
  ephemeral = var.ephemeral
  is_public = var.is_public

  # Opcional: especificar extra_specs si quieres
  extra_specs = var.extra_specs
}
