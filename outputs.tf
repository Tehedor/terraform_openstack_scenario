output "admin_ssh_ip" {
  description = "Dirección IP flotante para acceder al servidor de administración por SSH (puerto 2025)"
  value       = module.admin_vm.floating_ip
}

output "service_access_ip" {
  description = "Dirección IP flotante para acceder al servicio web (Load Balancer)"
  value       = module.loadbalancer.floating_ip
}

output "admin_key_private" {
  description = "Clave privada SSH para el servidor de administración (si se creó un keypair)"
  value       = module.admin_vm.private_key
  sensitive   = true
}
