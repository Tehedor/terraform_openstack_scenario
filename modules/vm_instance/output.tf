output "instance_id" {
  description = "La ID única de la instancia VM"
  value       = openstack_compute_instance_v2.vm[*].id
}

output "internal_ip" {
  description = "Dirección IP interna de la VM (fixed_ip_v4)"
  value = openstack_compute_instance_v2.vm.network[0].fixed_ip_v4
}

output "floating_ip" {
  description = "Dirección IP flotante asignada a la VM (vacío si no está asignada)"
  value = var.assign_floating_ip ? openstack_networking_floatingip_v2.fip[0].address : null
}


output "port_id" {
  value = openstack_compute_instance_v2.vm.network[0].port
}

output "private_key" {
  description = "Clave privada del keypair (solo si se creó)"
  value       = length(openstack_compute_keypair_v2.key) > 0 ? openstack_compute_keypair_v2.key[0].private_key : null
}

