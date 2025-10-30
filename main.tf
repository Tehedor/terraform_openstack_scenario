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

# ---------------------------------------------------------
# 2. SERVIDORES
# ---------------------------------------------------------

# Servidor de Administración (ADMIN)
module "admin_vm" {
  source = "./modules/vm_instance"

  name            = "ADMIN"
  image           = var.image_base_name
  flavor          = var.flavor_web
  key_pair        = var.key_pair_name
  security_groups = [openstack_networking_secgroup_v2.my_security_group.name]

  network_id             = module.networking.network_id # Conectado a Net1
  asign_multiple_network = true
  second_network_id      = module.networking2.network_id # Conectado a Net2

  # Configuración específica de ADMIN
  user_data_file     = "./cloud-init-scripts/admin_init.yaml"
  assign_floating_ip = true # Requisito: ADMIN tendrá IP flotante [cite: 79]
  ssh_port           = 2025 # Requisito: Puerto SSH personalizado [cite: 149, 150]
}

# Servidores Web (S1, S2, S3) - Usando una cuenta dinámica para la escalabilidad
module "web" {
  source = "./modules/vm_instance"

  count = 3 # Despliega 3 servidores S1, S2, S3 [cite: 41]

  name     = "s${count.index + 1}"
  image    = var.image_base_name
  flavor   = var.flavor_web
  key_pair = var.key_pair_name

  network_id             = module.networking.network_id # Conectado a Net1
  asign_multiple_network = true
  second_network_id      = module.networking2.network_id # Conectado a Net2

  # Configuraciones específicas
  user_data_file     = "./cloud-init-scripts/web_init.yaml"
  assign_floating_ip = false
}

# Servidor de Base de Datos (BBDD)
module "db_bbdd" {
  source = "./modules/vm_instance"

  name     = "BBDD"
  image    = var.image_base_name
  flavor   = var.flavor_db
  key_pair = var.key_pair_name

  network_id = module.networking2.network_id # Conectado a Net2

  # Configuraciones específicas
  user_data_file     = "./cloud-init-scripts/db_init.yaml"
  assign_floating_ip = false # BBDD no tiene salida a Internet/IP flotante [cite: 51]
}

# # ---------------------------------------------------------
# # 3. LOAD BALANCER (OCTAVIA)
# # ---------------------------------------------------------
# # Usar los recursos nativos de Octavia (LBaaS) [cite: 98]
# module "loadbalancer" {
#   source = "./modules/loadbalancer"

#   # Conecta el LB a la red Net1
#   network_id = module.networking.network_id
#   subnet_id  = module.networking.subnet_id

#   # Miembros del pool del LB: IDs de los 3 servidores web creados arriba
#   member_ids = openstack_compute_instance_v2.web.*.id

#   # El LB necesita una IP flotante para que los clientes accedan [cite: 88]
#   assign_floating_ip = true
# }

# # ---------------------------------------------------------
# # 4. FIREWALL (FWaaS) y GRUPOS DE SEGURIDAD
# # ---------------------------------------------------------
# # Se asume que el router que conecta Net1 a ExtNet se creará aquí o en el módulo 'security'.
# # Por simplicidad, se puede implementar el firewall como un Security Group "open" en este nivel [cite: 120]
# # El módulo 'security' debería gestionar el FWaaS completo (reglas y políticas)[cite: 103].
# module "security" {
#   source = "./modules/security"
#   # Le pasamos la ID de la red para asociar el router y el FWaaS
#   network_id = module.networking.network_id
#   admin_ip   = module.admin_vm.internal_ip     # Necesario para la regla SSH 2025 [cite: 107]
#   lb_ip      = module.loadbalancer.internal_ip # Necesario para la regla HTTP 80 [cite: 108]
# }