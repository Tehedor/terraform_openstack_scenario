terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

resource "openstack_lb_loadbalancer_v2" "loadBalancer" {
  name          = var.lb_name
  vip_subnet_id = var.subnet_id
}

resource "openstack_lb_listener_v2" "listener_lb" {
  name            = "listener_${var.lb_name}"
  protocol        = var.protocol
  protocol_port   = var.protocol_port
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadBalancer.id
}

resource "openstack_lb_pool_v2" "pool_lb" {
  name        = "pool_${var.lb_name}"
  protocol    = var.protocol
  lb_method   = var.lb_method
  listener_id = openstack_lb_listener_v2.listener_lb.id
}

resource "openstack_lb_member_v2" "members_lb" {
  count         = var.num_servers
  address       = var.server_ips[count.index]
  protocol_port = var.protocol_port
  pool_id       = openstack_lb_pool_v2.pool_lb.id
  subnet_id     = var.subnet_id
}


resource "openstack_networking_floatingip_v2" "fip" {
  count = var.assign_floating_ip ? 1 : 0
  pool  = "ExtNet" 
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  count       = var.assign_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  port_id     = openstack_lb_loadbalancer_v2.loadBalancer.vip_port_id
}
