# Variables para la regla SSH
variable "name" {
  description = "Nombre de la regla de firewall para SSH"
  type        = string
}

variable "protocol" {
  description = "Protocolo para la regla SSH"
  type        = string
}

variable "ssh_access" {
  description = "Acción para la regla SSH (allow/deny)"
  type        = string
}

variable "destination_port" {
  description = "Puerto destino para la regla SSH"
  type        = string
}

variable "source_ip_address" {
  description = "Dirección IP origen para la regla SSH"
  type        = string
}

variable "destination_ip_address" {
  description = "Dirección IP destino para la regla SSH"
  type        = string
}

# Variables para la regla HTTP
variable "rule1_name" {
  description = "Nombre de la regla de firewall para HTTP"
  type        = string
}

variable "rule1_protocol" {
  description = "Protocolo para la regla HTTP"
  type        = string
}

variable "rule1_action" {
  description = "Acción para la regla HTTP (allow/deny)"
  type        = string
}

variable "rule1_destination_ip_address" {
  description = "Dirección IP destino para la regla HTTP"
  type        = string
}

variable "rule1_destination_port" {
  description = "Puerto destino para la regla HTTP"
  type        = string
}

variable "rule1_source_ip_address" {
  description = "Dirección IP origen para la regla HTTP"
  type        = string
}

# Variables para la regla de acceso interno
variable "rule2_name" {
  description = "Nombre de la regla de firewall para acceso interno"
  type        = string
}

variable "rule2_protocol" {
  description = "Protocolo para la regla de acceso interno"
  type        = string
}

variable "rule2_action" {
  description = "Acción para la regla de acceso interno (allow/deny)"
  type        = string
}

variable "rule2_source_ip_address" {
  description = "Dirección IP origen para la regla de acceso interno"
  type        = string
}

# Variables para las políticas
variable "policy_ingress_name" {
  description = "Nombre de la política de ingreso"
  type        = string
}

variable "policy_egress_name" {
  description = "Nombre de la política de egreso"
  type        = string
}

variable "router_port_id" {
  description = "ID del puerto del router"
  type        = string
}

# Variable para el grupo de firewall
variable "group_name" {
  description = "Nombre del grupo de firewall"
  type        = string
}
