# Data source to get the existing images information
data "openstack_images_image_v2" "jammy" {
  name = "jammy-server-cloudimg-amd64-vnx"
}

# Data source to get the existing flavours information
data "openstack_compute_flavor_v2" "m1_smaller" {
  name = "m1.smaller"
}

# Data source to get the existing network information
data "openstack_networking_network_v2" "net0" {
  name = "net0"
}


resource "openstack_compute_instance_v2" "vm2" {
  name        = "vm2"
  image_name  = data.openstack_images_image_v2.jammy.name
  flavor_name = data.openstack_compute_flavor_v2.m1_smaller.name
  network {
    name = data.openstack_networking_network_v2.net0.name
  }
  user_data = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - apache2
    runcmd:
      - service start apache2
      - echo "VM lauched by Terraform" > /root/info.txt
  EOT
}