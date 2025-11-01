terraform {
  # Aquí se declaran los proveedores requeridos para este módulo.
  # `openstack` es el proveedor que permite a Terraform interactuar con
  # una nube OpenStack (crear redes, subredes, instancias, etc.).
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0" # Restringe la versión del proveedor a la serie 1.53.x
    }
  }
}

# Creates a firewall rule to allow SSH access on port 2020 from any IP address.
resource "openstack_fw_rule_v2" "ssh_access" {
  name                   = var.name
  protocol               = var.protocol
  action                 = var.ssh_access
  destination_ip_address = var.destination_ip_address
  destination_port       = var.destination_port
  source_ip_address      = "0.0.0.0/0"
}

# Creates a firewall rule to allow HTTP access on port 80 from any IP address.
resource "openstack_fw_rule_v2" "http_access" {
  name                   = var.rule1_name
  protocol               = var.rule1_protocol
  action                 = var.rule1_action
  destination_ip_address = var.rule1_destination_ip_address
  destination_port       = var.rule1_destination_port
  source_ip_address      = var.rule1_source_ip_address
}

# Creates a firewall rule to allow internal access for any protocol from any IP address.
resource "openstack_fw_rule_v2" "internal_access" {
  name              = var.rule2_name
  protocol          = var.rule2_protocol
  action            = var.rule2_action
  source_ip_address = var.rule2_source_ip_address
}

resource "openstack_networking_secgroup_v2" "my_security_group" {
 name = "open"
 description = "Grupo de Seguridad para permitir todo el trafico"
 delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_ingress"{
 direction = "ingress"
 ethertype = "IPv4"
 protocol = "tcp"
 remote_ip_prefix = "0.0.0.0/0"
 security_group_id = openstack_networking_secgroup_v2.my_security_group.id
}
resource "openstack_networking_secgroup_rule_v2" "security_group_rule_engress"{
 direction = "egress"
 ethertype = "IPv4"
 protocol = "tcp"
 remote_ip_prefix = "0.0.0.0/0"
 security_group_id = openstack_networking_secgroup_v2.my_security_group.id
}

# Creates a firewall group and associates it with the ingress and egress firewall policies.
resource "openstack_fw_group_v2" "firewall_group" {
  name = var.group_name

  ingress_firewall_policy_id = openstack_fw_policy_v2.ingress_policy.id
  egress_firewall_policy_id  = openstack_fw_policy_v2.egress_policy.id

  ports = [var.router_port_id]
}