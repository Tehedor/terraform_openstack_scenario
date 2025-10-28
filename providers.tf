terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  user_name           = var.openstack_user_name
  password            = var.openstack_password
  tenant_name         = var.openstack_tenant_name
  user_domain_name    = var.openstack_user_domain_name
  project_domain_name = var.openstack_project_domain_name
  auth_url            = var.openstack_auth_url
  region              = var.openstack_region
}
