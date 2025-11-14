variable "name" {
  description = "Nombre del grupo de firewall"
  type        = string
  default     = "my_firewall_group"
}

variable "fw_rules" {
  description = "Lista de reglas de firewall"
  type = list(object({
    name                   = optional(string)
    direction              = optional(string)
    protocol               = optional(string)
    action                 = optional(string)
    destination_ip_address = optional(string)
    destination_port       = optional(string)
    source_ip_address      = optional(string)
  }))
  default = []
}

variable "fw_policy" {
  description = "Lista de políticas de firewall"
  type = list(object({
    name  = optional(string)
    rules = optional(list(string))
  }))
  default = []
}

variable "ingress_firewall_policy_id" {
  description = "ID de la política de firewall de entrada"
  type        = string
  default     = null
}

variable "egress_firewall_policy_id" {
  description = "ID de la política de firewall de salida"
  type        = string
  default     = null
}

variable "ports" {
  description = "Lista de IDs de puertos (VMs, LoadBalancer, etc.) a asociar al firewall"
  type        = list(string)
  default     = []
}

variable "depends_on_resources" {
  description = "Lista de recursos de los que dependerá este módulo"
  type        = list(any)
  default     = []
}