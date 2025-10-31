output "loadbalancer_vip_address" {
  description = "The VIP address of the load balancer"
  value       = openstack_lb_loadbalancer_v2.loadBalancer.vip_address
}