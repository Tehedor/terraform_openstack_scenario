terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}


resource "openstack_fw_rule_v2" "rule" {
  count = length(var.fw_rules)

  name      = lookup(var.fw_rules[count.index], "name", "default_rule_name")
  protocol  = lookup(var.fw_rules[count.index], "protocol", "any")
  action    = lookup(var.fw_rules[count.index], "action", "allow")

  destination_ip_address = lookup(var.fw_rules[count.index], "destination_ip_address", null)
  destination_port       = lookup(var.fw_rules[count.index], "destination_port", null)
  source_ip_address      = lookup(var.fw_rules[count.index], "source_ip_address", null)
}

# Crea las políticas de firewall dinámicamente
resource "openstack_fw_policy_v2" "policy" {
  count = length(var.fw_policy)

  name = var.fw_policy[count.index].name

  # Mapea nombres de reglas → IDs
  rules = [
    for r in var.fw_policy[count.index].rules :
    openstack_fw_rule_v2.rule[
      index(
        [for rr in openstack_fw_rule_v2.rule : rr.name],
        r
      )
    ].id
  ]
}

# Crea el grupo de firewall y asocia las políticas
resource "openstack_fw_group_v2" "firewall_group" {
  name = var.name

  ingress_firewall_policy_id = openstack_fw_policy_v2.policy[0].id
  egress_firewall_policy_id  = openstack_fw_policy_v2.policy[1].id

  ports = var.ports
}
