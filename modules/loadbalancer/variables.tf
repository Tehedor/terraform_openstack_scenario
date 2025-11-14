variable "lb_name" {
  description = "Nombre del balanceador de carga"
  type        = string
}

variable "network_id" {
  description = "ID de la red donde se ubicarán los miembros del balanceador de carga"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se ubicará el VIP del balanceador de carga"
  type        = string
}

variable "protocol" {
  description = "Protocolo que utilizará el balanceador de carga (HTTP, HTTPS, TCP, etc.)"
  type        = string
}

variable "protocol_port" {
  description = "Puerto en el que escuchará el balanceador de carga"
  type        = number
}

variable "lb_method" {
  description = "Método de balanceo de carga (ROUND_ROBIN, LEAST_CONNECTIONS, etc.)"
  type        = string
}

variable "num_servers" {
  description = "Número de servidores que se incluirán en el pool del balanceador"
  type        = number
}

variable "server_ips" {
  description = "Lista de IPs fijas de los servidores web que se añadirán al pool del balanceador"
  type        = list(string)
}

variable "assign_floating_ip" {
  description = "Si es true, asigna una IP flotante al Load Balancer"
  type        = bool
  default     = false
}
