terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

resource "openstack_networking_secgroup_v2" "my_security_group" {
  name                 = var.security_group_name
  description          = var.description
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule" {
  count             = length(var.security_group_rules)
  direction         = var.security_group_rules[count.index].direction
  ethertype         = var.security_group_rules[count.index].ethertype
  protocol          = var.security_group_rules[count.index].protocol
  remote_ip_prefix  = var.security_group_rules[count.index].remote_ip_prefix
  security_group_id = openstack_networking_secgroup_v2.my_security_group.id

  port_range_min    = lookup(var.security_group_rules[count.index], "port_range_min", null)
  port_range_max    = lookup(var.security_group_rules[count.index], "port_range_max", null)
}