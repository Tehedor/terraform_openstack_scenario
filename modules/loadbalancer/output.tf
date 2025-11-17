output "loadbalancer_vip_address" {
  description = "The VIP address of the load balancer"
  value       = openstack_lb_loadbalancer_v2.loadBalancer.vip_address
}

output "floating_ip" {
  description = "Dirección IP flotante asignada a la VM (vacío si no está asignada)"
  value       = var.assign_floating_ip ? openstack_networking_floatingip_v2.fip[0].address : null
}