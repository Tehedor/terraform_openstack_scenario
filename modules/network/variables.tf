variable "network_name" {
  description = "Nombre que se le dará a la red (ej: Net1 o Net2)"
  type        = string
}

variable "subnet_name" {
  description = "Nombre que se le dará a la subred (ej: subnet1 o subnet2)"
  type        = string
}

variable "cidr" {
  description = "Rango CIDR de la subred (ej: 10.1.2.0/24)"
  type        = string
}