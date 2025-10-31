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
  value = [for n in openstack_compute_instance_v2.vm : n.network[0].fixed_ip_v4]
}

# Dirección IP flotante (si existe)
output "floating_ip" {
  description = "Dirección IP flotante asignada a la VM (vacío si no está asignada)"
  # Usa un splat (*) para devolver el valor solo si count > 0, sino devuelve una lista vacía.
  value = try(openstack_networking_floatingip_v2.fip[0].address, null)
}

output "admin_internal_ip" {
  description = "Dirección IP interna de la VM admin (fixed_ip_v4)"
  value       = openstack_compute_instance_v2.admin.network.0.fixed_ip_v4
}