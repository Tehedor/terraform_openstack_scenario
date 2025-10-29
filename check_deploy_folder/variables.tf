# variables.tf

variable "image_base_name" {
  description = "Nombre de la imagen base de Ubuntu cloud-img (ej: jammy-server-cloudimg-amd64-vnx)"
  type        = string
  default     = "jammy-server-cloudimg-amd64-vnx"
}

variable "flavor_web" {
  description = "Flavor de las VMs para servidores web y admin (S1, S2, S3, ADMIN)"
  type        = string
  default     = "m1.small"
}

variable "flavor_db" {
  description = "Flavor de la VM de la base de datos (puede ser más grande)"
  type        = string
  default     = "m1.medium"
}

variable "key_pair_name" {
  description = "Nombre del Key Pair (debe crearse previamente con CLI o Terraform)"
  type        = string
  default     = "admin_key"
}

# Redes
variable "net1_cidr" {
  description = "CIDR para la red Net1 (servidores web, admin, lb)"
  type        = string
  default     = "10.1.2.0/24"
}

variable "net2_cidr" {
  description = "CIDR para la red Net2 (bbdd, storage)"
  type        = string
  default     = "10.1.3.0/24"
}