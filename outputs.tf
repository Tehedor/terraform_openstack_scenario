# # outputs.tf

output "admin_ssh_ip" {
  description = "Dirección IP flotante para acceder al servidor de administración por SSH (puerto 2025)"
  value       = module.admin_vm.floating_ip
}

output "service_access_ip" {
  description = "Dirección IP flotante para acceder al servicio web (Load Balancer)"
  value       = module.loadbalancer.floating_ip
}

# output "web_server_ips" {
#   description = "Direcciones IP internas de los servidores web (S1, S2, S3)"
#   value       = openstack_compute_instance_v2.web.*.network.0.fixed_ip_v4
# }

# output "database_ip" {
#   description = "Dirección IP interna de la Base de Datos (accesible solo desde Net1/Net2)"
#   value       = module.db_bbdd.internal_ip
# }

output "admin_vm_internal_ip" {
  value = module.admin_vm.internal_ip
}

output "loadbalancer_lb_port_id" {
  value = module.loadbalancer.lb_port_id
}

output "admin_port" {
  value = module.admin_vm.port_id
}

# output "web_vms_ports" {
#   value = module.web[*].port_id
# }
