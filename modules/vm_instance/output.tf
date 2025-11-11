# ./modules/vm_instance/output.tf

# ID de la instancia, necesaria para el Load Balancer
output "instance_id" {
  description = "La ID única de la instancia VM"
  value       = openstack_compute_instance_v2.vm[*].id
}

# Dirección IP interna (fixed_ip)
output "internal_ip" {
  description = "Dirección IP interna de la VM (fixed_ip_v4)"
  # Asumimos una sola red [0]
  value = openstack_compute_instance_v2.vm.network[0].fixed_ip_v4
}

# Dirección IP flotante (si existe)
output "floating_ip" {
  description = "Dirección IP flotante asignada a la VM (vacío si no está asignada)"
  # Usa un splat (*) para devolver el valor solo si count > 0, sino devuelve una lista vacía.
  value = var.assign_floating_ip ? openstack_networking_floatingip_v2.fip[0].address : null
}

output "web_tar_present" {
  description = "True si tar_file (base64) está presente"
  value       = var.tar_file != null && var.tar_file != ""
}

output "web_tar_base64_length" {
  description = "Longitud de la cadena base64 pasada en tar_file (0 si no existe)"
  value       = var.tar_file != null ? length(var.tar_file) : 0
}

output "web_tar_sha256" {
  description = "SHA256 del contenido decodificado del tar ('' si no existe)"
  # value       = var.tar_file != null && var.tar_file != "" ? sha256(base64decode(var.tar_file)) : ""
  value = var.tar_file != null && var.tar_file != "" ? sha256(var.tar_file) : ""
}


# terraform output web_tar_present
# terraform output web_tar_base64_length
# terraform output web_tar_sha256