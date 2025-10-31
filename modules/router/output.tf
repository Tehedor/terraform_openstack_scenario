output "router_port_id" {
  description = "ID of the router port"
  value       = openstack_networking_port_v2.router_port.id
}

output "router_id" {
  description = "ID of the router"
  value       = openstack_networking_router_v2.router.id
}