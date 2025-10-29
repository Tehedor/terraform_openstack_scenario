output "net1_id" {
  description = "ID de la primera red (net1)"
  value       = openstack_networking_network_v2.net1.id
}

output "net1_name" {
  description = "Nombre de la primera red"
  value       = openstack_networking_network_v2.net1.name
}

output "subnet1_id" {
  description = "ID de la primera subred (subnet1)"
  value       = openstack_networking_subnet_v2.subnet1.id
}

output "subnet1_cidr" {
  description = "CIDR de la primera subred"
  value       = openstack_networking_subnet_v2.subnet1.cidr
}

output "net2_id" {
  description = "ID de la segunda red (net2)"
  value       = openstack_networking_network_v2.net2.id
}

output "net2_name" {
  description = "Nombre de la segunda red"
  value       = openstack_networking_network_v2.net2.name
}

output "subnet2_id" {
  description = "ID de la segunda subred (subnet2)"
  value       = openstack_networking_subnet_v2.subnet2.id
}

output "subnet2_cidr" {
  description = "CIDR de la segunda subred"
  value       = openstack_networking_subnet_v2.subnet2.cidr
}
