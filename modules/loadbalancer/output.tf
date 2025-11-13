output "loadbalancer_vip_address" {
  description = "The VIP address of the load balancer"
  value       = openstack_lb_loadbalancer_v2.loadBalancer.vip_address
}

# ID del puerto VIP del Load Balancer (para asociar en FWaaS o debugging)
output "lb_port_id" {
  description = "ID del puerto VIP del Load Balancer"
  value       = openstack_lb_loadbalancer_v2.loadBalancer.vip_port_id
}
