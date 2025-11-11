# ./modules/network/output.tf

output "network_id" {
  description = "ID de la red creada, necesaria para conectar VMs y Routers"
  value       = openstack_networking_network_v2.net.id
}

output "subnet_id" {
  description = "ID de la subred creada, necesaria para el Load Balancer"
  value       = openstack_networking_subnet_v2.subnet.id
}

output "network_name" {
  description = "Nombre de la red"
  value       = openstack_networking_network_v2.net.name
}


output "cidr_block" {
  description = "Bloque CIDR de la subred"
  value       = openstack_networking_subnet_v2.subnet.cidr
}