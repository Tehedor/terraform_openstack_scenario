variable "openstack_user_name" {
  description = "OpenStack user name"
  type        = string
}

variable "openstack_password" {
  description = "OpenStack user password (sensitive)"
  type        = string
  sensitive   = true
}

variable "openstack_tenant_name" {
  description = "OpenStack tenant (project) name"
  type        = string
}

variable "openstack_user_domain_name" {
  description = "OpenStack user domain name"
  type        = string
  default     = "Default"
}

variable "openstack_project_domain_name" {
  description = "OpenStack project domain name"
  type        = string
  default     = "Default"
}

variable "openstack_auth_url" {
  description = "Keystone auth URL"
  type        = string
}

variable "openstack_region" {
  description = "OpenStack region"
  type        = string
  default     = "RegionOne"
}
