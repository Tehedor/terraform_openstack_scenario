# main.tf

# ---------------------------------------------------------
# 1. REDES (NET1 y NET2)
# ---------------------------------------------------------
# Módulo para crear Net1 (App/Admin)
module "networking" {
  source = "./modules/network"

  network_name = "Net1"
  subnet_name  = "subnet1"
  cidr         = var.net1_cidr
}

# Módulo para crear Net2 (DB/Storage)
module "networking2" {
  source = "./modules/network"

  network_name = "Net2"
  subnet_name  = "subnet2"
  cidr         = var.net2_cidr
}

# Módulo para crear el router que conecta Net1 a ExtNet
module "router" {
  source = "./modules/router"

  router_name = "r0"
  network_id  = module.networking.network_id # Conectar a Net1
  subnet_id   = module.networking.subnet_id  # Conectar a la subred
  ext_network = var.ext_network
  gateway     = cidrhost(var.net1_cidr, 1) # Asignar la IP de gateway de Net1
}

# ---------------------------------------------------------
# 2. SERVIDORES
# ---------------------------------------------------------

# Servidor de Administración (ADMIN)
# module "admin_vm" {
#   source = "./modules/vm_instance"

#   name            = "ADMIN"
#   image           = var.image_base_name
#   flavor          = var.flavor_web
#   key_pair        = var.key_pair_name
#   security_groups = [openstack_networking_secgroup_v2.my_security_group.name]

#   network_id             = module.networking.network_id # Conectado a Net1
#   asign_multiple_network = true
#   second_network_id      = module.networking2.network_id # Conectado a Net2

#   # Configuración específica de ADMIN
#   # user_data_file     = "./cloud-init-scripts/admin_init.yaml"
#   assign_floating_ip = true # Requisito: ADMIN tendrá IP flotante [cite: 79]
#   ssh_port           = 2025 # Requisito: Puerto SSH personalizado [cite: 149, 150]
# }

# Servidores Web (S1, S2, S3) - Usando una cuenta dinámica para la escalabilidad
# module "web" {
#   source = "./modules/vm_instance"

#   count = 3 # Despliega 3 servidores S1, S2, S3 [cite: 41]

#   name     = "s${count.index + 1}"
#   image    = var.image_base_name
#   flavor   = var.flavor_web
#   key_pair = var.key_pair_name

#   network_id             = module.networking.network_id # Conectado a Net1
#   asign_multiple_network = true
#   second_network_id      = module.networking2.network_id # Conectado a Net2

#   # Configuraciones específicas
#   user_data_file     = "./cloud-init-scripts/web_init.yaml"
#   assign_floating_ip = false
# }
module "web" {
  source = "./modules/vm_instance"

  count = 3

  name     = "s${count.index + 1}"
  image    = var.image_base_name
  flavor   = var.flavor_web
  key_pair = "" # Opcional, web normalmente no necesita SSH

  network_id             = module.networking.network_id
  asign_multiple_network = true
  second_network_id      = module.networking2.network_id

  # Configuraciones específicas de web
  assign_floating_ip = false

  user_data_file = "./cloud-init-scripts/web_init.tpl"
  # tar_file       = "${path.module}/cloud_init_files/00_tar_files/web_files.tar.gz"
    // ...existing code...
  tar_file = filebase64("${path.module}/cloud_init_files/00_tar_files/web_files.tar.gz")
  # ...existing code...
  db_host        = var.db_host
  db_user        = var.db_user
  db_pass        = var.db_pass
  db_name        = var.db_name

  depends_on = [
    module.networking,
    module.networking2,
    module.router
  ]

}


# Servidor de Base de Datos (BBDD)
# module "db_bbdd" {
#   source = "./modules/vm_instance"

#   name     = "BBDD"
#   image    = var.image_base_name
#   flavor   = var.flavor_web
#   key_pair = var.key_pair_name

#   network_id             = module.networking2.network_id # Conectado a Net2
#   asign_multiple_network = false


#   # Configuraciones específicas
#   user_data_file     = "./cloud-init-scripts/db_init.yaml"
#   assign_floating_ip = false # BBDD no tiene salida a Internet/IP flotante [cite: 51]
# }

# # ---------------------------------------------------------
# # 3. LOAD BALANCER (OCTAVIA)
# # ---------------------------------------------------------
# Usar los recursos nativos de Octavia (LBaaS) [cite: 98]
# module "loadbalancer" {
#   source = "./modules/loadbalancer"

#   lb_name = var.lb_name
#   # Conecta el LB a la red Net1
#   network_id    = module.networking.network_id
#   subnet_id     = module.networking.subnet_id
#   protocol      = "TCP"
#   protocol_port = 80
#   lb_method     = "ROUND_ROBIN"
#   num_servers   = 3
#   server_ips    = flatten(module.web[*].internal_ip)
# }

# # ---------------------------------------------------------
# # 4. FIREWALL (FWaaS) y GRUPOS DE SEGURIDAD
# # ---------------------------------------------------------
# Se asume que el router que conecta Net1 a ExtNet se creará aquí o en el módulo 'security'.
# Por simplicidad, se puede implementar el firewall como un Security Group "open" en este nivel [cite: 120]
# El módulo 'security' debería gestionar el FWaaS completo (reglas y políticas)[cite: 103].
# module "firewall" {
#   source = "./modules/firewall"
#   # Le pasamos la ID de la red para asociar el router y el FWaaS
#   name                   = "ssh_access"
#   protocol               = "tcp"
#   ssh_access             = "allow"
#   destination_ip_address = module.admin_vm.internal_ip
#   destination_port       = "2020"
#   source_ip_address      = "0.0.0.0/0"

#   rule1_name                   = "http_access"
#   rule1_protocol               = "tcp"
#   rule1_action                 = "allow"
#   rule1_destination_ip_address = module.loadbalancer.loadbalancer_vip_address
#   rule1_destination_port       = "80"
#   rule1_source_ip_address      = "0.0.0.0/0"

#   rule2_name              = "internal_access"
#   rule2_protocol          = "any"
#   rule2_action            = "allow"
#   rule2_source_ip_address = "0.0.0.0/0"

#   policy_ingress_name = "ingress_policy"

#   policy_egress_name = "egress_policy"

#   router_port_id = module.router.router_port_id

#   group_name = "my_firewall_group"
# }