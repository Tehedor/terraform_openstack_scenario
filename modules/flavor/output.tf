output "flavor_id" {
  value       = openstack_compute_flavor_v2.custom_flavor.id
  description = "ID of the created flavor"
}

output "flavor_name" {
  value       = openstack_compute_flavor_v2.custom_flavor.name
  description = "Name of the created flavor"
}
