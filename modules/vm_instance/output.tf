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


# Puerto principal de la instancia (para usar en FWaaS u otras asociaciones)
output "port_id" {
  value = openstack_compute_instance_v2.vm[*].network[0].port
}




# Clave privada generada por OpenStack (solo si Terraform crea el keypair)
output "private_key" {
  description = "Clave privada del keypair (solo si se creó)"
  value       = length(openstack_compute_keypair_v2.key) > 0 ? openstack_compute_keypair_v2.key[0].private_key : null
}

