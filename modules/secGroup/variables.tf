variable "security_group_name" {
  description = "The name of the security group."
  type        = string
}


variable "security_group_rules" {
  description = "A list of additional security group rules to apply."
  type = list(object({
    direction        = string
    ethertype        = string
    protocol         = string
    remote_ip_prefix = string
  }))
  default = []
}
variable "description" {
  type        = string
  description = "Description of the security group."
}