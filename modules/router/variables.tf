variable "router_name" {
  description = "Nombre que se le dará al router"
  type        = string
}

variable "network_id" {
  description = "ID de la red a la que se conectará el router"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred a la que se conectará el router"
  type        = string
}

variable "ext_network" {
  description = "Nombre o ID de la red externa (ExtNet) para el gateway del router"
  type        = string
}

variable "gateway" {
  description = "Dirección IP que se asignará como gateway en la red conectada al router"
  type        = string
}