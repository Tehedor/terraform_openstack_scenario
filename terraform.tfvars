# terraform.tfvars

# Puedes usar este archivo para sobrescribir los 'defaults' de variables.tf
# key_pair_name = "mi_clave_ssh"
# flavor_web    = "m1.tiny"


# Base de datos contraseña
# variables_web.tfvars
# image        = "jammy-server-cloudimg-amd64-vnx"
# flavor       = "m1.smaller"
# key_pair     = "" # no necesitamos keypair para web
# network_id   = "id_red_principal"
# asign_multiple_network = true
# second_network_id      = "id_red_secundaria"
# security_groups        = ["web-sg"]
# assign_floating_ip     = false
# user_data_file         = "${path.module}/cloud-init.tpl"

db_host = "mysql.internal"
db_user = "webuser"
db_pass = "secretpassword"
db_name = "usuarios_db"
