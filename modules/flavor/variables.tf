variable "auth_url" {
  type        = string
  description = "OpenStack authentication URL"
}

variable "tenant_name" {
  type        = string
  description = "Tenant/Project name"
}

variable "username" {
  type        = string
  description = "OpenStack username"
}

variable "password" {
  type        = string
  description = "OpenStack password"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region name"
  default     = "RegionOne"
}

variable "name" {
  type        = string
  description = "Flavor name"
  default     = "m1.custom"
}

variable "ram" {
  type        = number
  description = "RAM in MB"
  default     = 1024
}

variable "vcpus" {
  type        = number
  description = "Number of vCPUs"
  default     = 1
}

variable "disk" {
  type        = number
  description = "Root disk size in GB"
  default     = 10
}

variable "swap" {
  type        = number
  description = "Swap size in MB"
  default     = 0
}

variable "ephemeral" {
  type        = number
  description = "Ephemeral disk size in GB"
  default     = 0
}

variable "is_public" {
  type        = bool
  description = "Whether flavor is public"
  default     = true
}

variable "extra_specs" {
  type        = map(string)
  description = "Extra specifications for flavor"
  default     = {}
}
