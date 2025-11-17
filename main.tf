# main.tf

# ---------------------------------------------------------
# 0. FLAVORS
# ---------------------------------------------------------
module "flavor_db_web" {
  source = "./modules/flavor" 

  # Parámetros del flavor
  name        = "m1.db_1gb"
  ram         = 1024 # 1 GB
  vcpus       = 1
  disk        = 10
  swap        = 0
  ephemeral   = 0
  is_public   = true
  extra_specs = {}

  # Datos de autenticación OpenStack
  auth_url    = "http://controller:5000/v3"
  tenant_name = "admin"
  username    = "admin"
  password    = "xxxx"
  region      = "RegionOne"

}

module "flavor_storage" {
  source = "./modules/flavor" 
  
  # Parámetros del flavor
  name        = "m1.storage_1gb"
  ram         = 2048 # 2 GB
  vcpus       = 1
  disk        = 10
  swap        = 0
  ephemeral   = 0
  is_public   = true
  extra_specs = {}

  # Datos de autenticación OpenStack
  auth_url    = "http://controller:5000/v3"
  tenant_name = "admin"
  username    = "admin"
  password    = "xxxx"
  region      = "RegionOne"

}


# ---------------------------------------------------------
# 1. REDES (NET1 y NET2)
# ---------------------------------------------------------
# Módulo para crear Net1 (App/Admin)
module "networking" {
  source = "./modules/network"

  network_name = "Net1"
  subnet_name  = "subnet1"
  cidr         = var.net1_cidr
  has_internet = true
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
# 2. Security Group para permitir todo el tráfico
# ---------------------------------------------------------
module "security_group" {
  source              = "./modules/secGroup"
  security_group_name = "open"
  description         = "Grupo de Seguridad para permitir todo el trafico"

  security_group_rules = [
   {
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      direction        = "egress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "udp"
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      direction        = "egress"
      ethertype        = "IPv4"
      protocol         = "udp"
      remote_ip_prefix = "0.0.0.0/0"
    }
  ]
}




# ---------------------------------------------------------
# 3. SERVIDORES
# ---------------------------------------------------------
module "networking3" {
  source = "./modules/network"
  count  = 1

  network_name = "Net3"
  subnet_name  = "subnet3"
  cidr         = var.net3_cidr
  has_internet = var.create_temp_net
}

module "backup_router" {
  source = "./modules/router"
  count  = var.create_temp_net ? 1 : 0

  router_name = "backup_router"
  # conectar a Net3: usa los outputs del módulo networking3
  network_id  = module.networking3[0].network_id
  subnet_id   = module.networking3[0].subnet_id
  ext_network = var.ext_network
  gateway     = cidrhost(var.net3_cidr, 1)
}


# Servidor de Base de Datos (BBDD)
module "db_bbdd" {
  source = "./modules/vm_instance"

  name            = "BBDD"
  image           = var.image_base_name
  flavor          = module.flavor_db_web.flavor_name
  security_groups = [module.security_group.security_group_id]


  network_id = module.networking2.network_id 

  # Configuraciones específicas
  user_data_file     = "./cloud-init-scripts/db_init.tpl"
  assign_floating_ip = false 

  db_user                = var.db_user
  db_pass                = var.db_pass
  db_name                = var.db_name
  asign_multiple_network = true
  second_network_id      = module.networking3[0].network_id
}

module "object_storage" {
  source = "./modules/vm_instance"

  name   = "ObjectStorage"
  image  = var.image_base_name
  flavor = module.flavor_storage.flavor_name
  security_groups = [module.security_group.security_group_id]

  network_id             = module.networking2.network_id 
  asign_multiple_network = true
  second_network_id      = module.networking3[0].network_id

  # Configuraciones específicas
  user_data_file     = "./cloud-init-scripts/object_storage_init.tpl"
  assign_floating_ip = false 
}

# ---------------------------------------------------------
# 4. SERVIDORES
# ---------------------------------------------------------
# Servidor de Administración (ADMIN)
module "admin_vm" {
  source = "./modules/vm_instance"

  name   = "ADMIN"
  image  = var.image_base_name
  flavor = var.flavor_web

  create_keypair  = true
  key_pair        = var.key_pair_name
  security_groups = [module.security_group.security_group_id]

  network_id             = module.networking.network_id # Conectado a Net1
  asign_multiple_network = true
  second_network_id      = module.networking2.network_id 

  # Configuración específica de ADMIN
  user_data_file     = "./cloud-init-scripts/admin_init.tpl"
  assign_floating_ip = true 
  ssh_port           = 2025 
  }

module "web" {
  source = "./modules/vm_instance"

  count = 3

  name            = "s${count.index + 1}"
  image           = var.image_base_name
  flavor = module.flavor_db_web.flavor_name
  security_groups = [module.security_group.security_group_id]


  network_id             = module.networking.network_id
  asign_multiple_network = true
  second_network_id      = module.networking2.network_id

  # Configuraciones específicas de web
  assign_floating_ip = false

  user_data_file = "./cloud-init-scripts/web_init.tpl"
  db_host = module.db_bbdd.internal_ip
  db_user = var.db_user
  db_pass = var.db_pass
  db_name = var.db_name

  object_storage_host = module.object_storage.internal_ip

  depends_on = [
    module.networking,
    module.networking2,
    module.router,
    module.db_bbdd,
    module.object_storage
  ]

}


# # ---------------------------------------------------------
# # 5. LOAD BALANCER (OCTAVIA)
# # ---------------------------------------------------------
module "loadbalancer" {
  source = "./modules/loadbalancer"

  lb_name = var.lb_name
  # Conecta el LB a la red Net1
  network_id    = module.networking.network_id
  subnet_id     = module.networking.subnet_id
  protocol      = "TCP"
  protocol_port = 80
  lb_method     = "ROUND_ROBIN"
  num_servers        = length(module.web)
  server_ips         = flatten(module.web[*].internal_ip)
  depends_on         = [module.web]
  assign_floating_ip = true
}

# # ---------------------------------------------------------
# # 6. FIREWALL (FWaaS) y GRUPOS DE SEGURIDAD
# # ---------------------------------------------------------
module "firewall" {
  source = "./modules/firewall"

  ### REGLA SSH (EXTERIOR → ADMIN)
  fw_rules = [
    {
      name                   = "ssh_access"
      direction              = "ingress"
      protocol               = "tcp"
      action                 = var.actions_ssh_admin
      destination_ip_address = module.admin_vm.internal_ip
      destination_port       = "2025"
    },

    ### REGLA HTTP (EXTERIOR → LB)
    {
      name                   = "http_access"
      direction              = "ingress"
      protocol               = "tcp"
      action                 = "allow"
      destination_ip_address = module.loadbalancer.loadbalancer_vip_address
      destination_port       = "80"
    },

    ### REGLA EGRESS (INTERIOR → CUALQUIERA)
    {
      name              = "internal_access"
      direction         = "egress"
      protocol          = "any"
      action            = "allow"
      source_ip_address = var.net1_cidr
    }
  ]

  fw_policy = [
    {
      name  = "ingress_policy"
      rules = ["ssh_access", "http_access"]
    },
    {
      name  = "egress_policy"
      rules = ["internal_access"]
    }
  ]

  ingress_firewall_policy_id = "ingress_policy"
  egress_firewall_policy_id  = "egress_policy"

  ports = [
    module.router.router_port_id 
  ]

  depends_on = [
    module.router,
    module.admin_vm,
    module.loadbalancer
  ]
}