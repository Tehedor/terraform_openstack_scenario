# ---------------------------------------------------------
# Variables VM instances
# ---------------------------------------------------------
variable "image_base_name" {
  description = "Nombre de la imagen base de Ubuntu cloud-img (ej: jammy-server-cloudimg-amd64-vnx)"
  type        = string
  default     = "jammy-server-cloudimg-amd64-vnx"
}

variable "flavor_web" {
  description = "Flavor de las VMs para servidores web y admin (S1, S2, S3, ADMIN)"
  type        = string
  default     = "m1.smaller"
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

variable "lb_name" {
  description = "Nombre del Load Balancer"
  type        = string
  default     = "LB"
}

variable "ext_network" {
  description = "Nombre de la red externa (ExtNet) para acceso a Internet"
  type        = string
  default     = "ExtNet"
}

# Modulo VM web
# ./variables.tf (root)
variable "db_host" {
  type        = string
  description = "Host de la base de datos para los servidores web"
  default     = "mysql.internal"
}

variable "db_user" {
  type        = string
  description = "Usuario de la base de datos para los servidores web"
  default     = "webuser"
}

variable "db_pass" {
  type        = string
  description = "Contraseña de la base de datos para los servidores web"
  sensitive   = true
  default     = "secretpassword"
}

variable "db_name" {
  type        = string
  description = "Nombre de la base de datos para los servidores web"
  default     = "usuarios_db"
}



# Temporal NET
variable "create_temp_net" {
  description = "Si true crea Net3 y el router temporal para dar salida a internet a la BBDD."
  type        = bool
  default     = true
}

variable "net3_cidr" {
  description = "CIDR para Net3 (solo para la BBDD temporalmente)."
  type        = string
  default     = "10.1.3.0/24"
}
