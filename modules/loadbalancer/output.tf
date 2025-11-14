output "loadbalancer_vip_address" {
  description = "The VIP address of the load balancer"
  value       = openstack_lb_loadbalancer_v2.loadBalancer.vip_address
}

# ID del puerto VIP del Load Balancer (para asociar en FWaaS o debugging)
output "lb_port_id" {
  description = "ID del puerto VIP del Load Balancer"
  value       = openstack_lb_loadbalancer_v2.loadBalancer.vip_port_id
}

output "floating_ip" {
  description = "Dirección IP flotante asignada a la VM (vacío si no está asignada)"
  value       = var.assign_floating_ip ? openstack_networking_floatingip_v2.fip[0].address : null
}


# output "lb_port_id" {
#   value = openstack_loadbalancer_v2.lb.vip_port_id
# }
