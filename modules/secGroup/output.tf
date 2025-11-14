output "security_group_description" {
  value = openstack_networking_secgroup_v2.my_security_group.description
}

output "security_group_rules" {
  value = openstack_networking_secgroup_rule_v2.security_group_rule.*.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = openstack_networking_secgroup_v2.my_security_group.id
}

output "security_group_name" {
  value = openstack_networking_secgroup_v2.my_security_group.name
}
