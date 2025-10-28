/* Variables para el módulo 01_networking */

variable "nombre_red" {
  description = "Nombre de la primera red"
  type        = string
}

variable "nombre_subred" {
  description = "Nombre de la primera subred"
  type        = string
}

variable "nombre_red2" {
  description = "Nombre de la segunda red"
  type        = string
}

variable "nombre_subred2" {
  description = "Nombre de la segunda subred"
  type        = string
}
variable "nombre_red" {
  description = "Nombre de la red"
  type        = string
}

variable "nombre_subred" {
  description = "Nombre de la subred"
  type        = string
} variable "openstack_user_name" {
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
