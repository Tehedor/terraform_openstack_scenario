# ./modules/vm_instance/variables.tf

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

variable "key_pair" {
  description = "Nombre del Key Pair de OpenStack para acceso SSH"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs de los Security Groups a asignar a la VM"
  type        = list(string)
  default     = []
}

variable "user_data_file" {
  description = "Ruta al fichero de cloud-init específico para la VM (ej: ../../cloud-init-scripts/admin_init.yaml)"
  type        = string
}

variable "assign_floating_ip" {
  description = "Si es 'true', se asigna una IP flotante a esta VM (solo para ADMIN y LB)"
  type        = bool
  default     = false
}