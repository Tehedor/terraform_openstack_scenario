variable "name" {
  description = "Nombre de la instancia de la máquina virtual (ej: 'ADMIN' o 's1')"
  type        = string
}

variable "image" {
  description = "Nombre de la imagen de OpenStack a usar (ej: jammy-server-cloudimg-amd64-vnx)"
  type        = string
}

variable "flavor" {
  description = "Nombre del flavor de OpenStack a usar (ej: 'm1.small')"
  type        = string
}

variable "network_id" {
  description = "ID de la red interna de OpenStack a la que se conectará la VM (ej: Net1 o Net2)"
  type        = string
}

variable "second_network_id" {
  description = "ID de la red interna de OpenStack a la que se conectará la VM (ej: Net1 o Net2)"
  type        = string
  default     = ""
}

variable "key_pair" {
  description = "Nombre del Key Pair de OpenStack para acceso SSH"
  type        = string
  default     = ""
}
variable "create_keypair" {
  description = "Si true, crear un keypair en OpenStack y devolver la private_key."
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "Nombre de los Security Groups a asignar a la VM"
  type        = list(string)
  default     = []
}

variable "user_data_file" {
  description = "Ruta al fichero de cloud-init específico para la VM (ej: ../../cloud-init-scripts/admin_init.yaml)"
  type        = string
  default     = ""
}

variable "assign_floating_ip" {
  description = "Si es 'true', se asigna una IP flotante a esta VM (solo para ADMIN y LB)"
  type        = bool
  default     = false
}

variable "ssh_port" {
  description = "Puerto SSH personalizado para la VM (solo para ADMIN)"
  type        = number
  default     = 22
}

variable "asign_multiple_network" {
  description = "Si es 'true', se asigna una segunda network(solo para ADMIN y S1,S2,S3)"
  type        = bool
  default     = false
}

variable "db_host" {
  type        = string
  default     = null
  description = "Host de la base de datos (opcional)"
}

variable "db_user" {
  type        = string
  default     = null
  description = "Usuario de la base de datos (opcional)"
}

variable "db_pass" {
  type        = string
  default     = null
  sensitive   = true
  description = "Contraseña de la base de datos (opcional)"
}

variable "db_name" {
  type        = string
  default     = null
  description = "Nombre de la base de datos (opcional)"
}

variable "object_storage_host" {
  type        = string
  description = "Host del servicio de Object Storage"
  default     = null
}


variable "ip_address" {
  description = "IP estática opcional a inyectar en la plantilla (opcional)."
  type        = string
  default     = ""
}