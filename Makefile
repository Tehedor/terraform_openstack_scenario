.PHONY: help fmt validate init clean check destroy_all deploy_all deploy_test

fmt:
	@echo "📝 Formateando código Terraform..."
	@terraform fmt -recursive

# Show a helpful list of make targets and usage
help:
	@echo "Makefile - lista de objetivos disponibles:" \
		&& echo "" \
		&& echo "BÁSICOS:" \
		&& echo "  help                 - Mostrar esta ayuda" \
		&& echo "  fmt                  - Formatear código Terraform (terraform fmt -recursive)" \
		&& echo "  init                 - Inicializar Terraform (terraform init)" \
		&& echo "  validate             - Validar la configuración Terraform (terraform validate)" \
		&& echo "  clean                - Limpiar archivos temporales (.terraform, .terraform.lock.hcl)" \
		&& echo "" \
		&& echo "CHEQUEOS:" \
		&& echo "  check                - init + fmt + validate" \
		&& echo "" \
		&& echo "DESPLIEGUE (targets):" \
		&& echo "  deploy-networking    - Desplegar redes y router (module.networking, networking2, router)" \
		&& echo "  deploy-admin         - Desplegar servidor ADMIN (module.admin_vm)" \
		&& echo "  deploy-webservers    - Desplegar servidores web (module.web)" \
		&& echo "  deploy_numb_web_servers - Desplegar N servidores web (uso: make deploy_numb_web_servers 12)" \
		&& echo "  deploy-db            - Desplegar Base de Datos (module.db_bbdd)" \
		&& echo "  deploy-object_storage- Desplegar Object Storage (module.object_storage)" \
		&& echo "  deploy-loadbalancer  - Desplegar Load Balancer (module.loadbalancer)" \
		&& echo "  deploy-firewall      - Desplegar Firewall (module.firewall)" \
		&& echo "  deploy_all           - Ejecutar check y aplicar toda la infraestructura" \
		&& echo "" \
		&& echo "KEYS & SSH:" \
		&& echo "  extract_key          - Extrae la clave privada admin a ./keys/admin_key.pem" \
		&& echo "  ssh_deny             - Denegar acceso SSH al ADMIN (apply var actions_ssh_admin=deny)" \
		&& echo "  ssh_allow            - Permitir acceso SSH al ADMIN (apply var actions_ssh_admin=allow)" \
		&& echo "  sshAdmin             - Conectar por SSH al servidor ADMIN usando la clave privada ./keys/admin_key.pem" \
		&& echo "" \
		&& echo "DESTRUCCIÓN (targets):" \
		&& echo "  destroy-networking   - Destruir redes y router (module.router, networking2, networking)" \
		&& echo "  destroy-admin        - Destruir ADMIN (module.admin_vm)" \
		&& echo "  destroy-webservers   - Destruir web servers (module.web)" \
		&& echo "  destroy-db           - Destruir Base de Datos (module.db_bbdd)" \
		&& echo "  destroy-storage      - Destruir Storage (module.storage)" \
		&& echo "  destroy-loadbalancer - Destruir LB (module.loadbalancer)" \
		&& echo "  destroy-firewall     - Destruir Firewall (module.firewall)" \
		&& echo "  destroy_all          - Destruir toda la infraestructura" \
		&& echo "" \
		&& echo "DIAGNÓSTICO & HERRAMIENTAS:" \
		&& echo "  graph                - Generar graph.png (terraform graph -> dot)" \
		&& echo "  cp_shared            - Copiar repo al shared del laboratorio VNX" \
		&& echo "" \
		&& echo "LAB / NODOS / SCRIPTS:" \
		&& echo "  run_nodes1           - Ejecutar get-openstack-tutorial.sh" \
		&& echo "  run_nodes2           - Crear/arrancar laboratorio VNX (vnx)" \
		&& echo "  run_problem_terraform- Reparar/instalar Terraform en el lab" \
		&& echo "  destroy_nodes        - Destruir nodos VNX" \
		&& echo "" \
		&& echo "OTROS / USO:" \
		&& echo "  clean                - Limpiar (.terraform, lock)" \
		&& echo "" \
		&& echo "Ejemplos:" \
		&& echo "  make deploy-networking" \
		&& echo "  make deploy-webservers" \
		&& echo "  make graph"

validate:
	@echo "✅ Validando configuración Terraform..."
	@terraform validate

init:
	@echo "🛠️ Inicializando Terraform..."
	@terraform init

clean:
	@echo "🧹 Limpiando archivos temporales..."
	@rm -rf .terraform .terraform.lock.hcl
	@echo "Limpieza completada."

check: init fmt validate
	@echo "✅ Chequeos de código completados satisfactoriamente."

destroy_all:
	@echo "💥 INICIANDO DESTRUCCIÓN DE TODA LA INFRAESTRUCTURA"
	@terraform destroy -auto-approve
	@echo "🗑️  DESTRUCCIÓN FINALIZADA."

deploy_all: check
	@echo "🌟 INICIANDO DESPLIEGUE COMPLETO DE ARQUITECTURA CON RED TEMPORAL"
	@terraform apply -auto-approve
	@echo "⏳ Esperando a que la BBDD y el Object Storage terminen de configurarse..."
	@sleep 120  # Espera 2 minutos (ajusta según el tiempo de cloud-init o instalación)
	@echo "🧹 Eliminando la conexión temporal a Net1 (retirando acceso a Internet de la BBDD)"
	@terraform apply -auto-approve -var="create_temp_net=false"
	@echo "🎉 ARQUITECTURA FINAL DESPLEGADA Y RED TEMPORAL ELIMINADA CON ÉXITO"


deploy_test: check
	@echo "🌟 INICIANDO DESPLIEGUE COMPLETO DE ARQUITECTURA"
	@terraform apply -auto-approve
# 	@terraform state pull | jq -r '.modules[] | .path[1:] as $module | .outputs | to_entries[] | "\($module).\(.key)=\(.value.value)"' > outputs.txt
	@echo "🎉 ARQUITECTURA COMPLETA DESPLEGADA con éxito."

deploy_no_net3: check
	@echo "🌟 INICIANDO DESPLIEGUE COMPLETO DE ARQUITECTURA SIN RED TEMPORAL"
	@terraform apply -auto-approve -var="create_temp_net=false"
	@echo "🎉 ARQUITECTURA FINAL DESPLEGADA SIN RED TEMPORAL con éxito."

# ---------------------------------------------------------
# OBJETIVOS ESPECÍFICOS DE DESPLIEGUE (Usando -target)
# ---------------------------------------------------------

.PHONY: deploy-networking deploy-loadbalancer deploy-admin deploy-webservers deploy-db deploy-object_storage

# 1. Redes (Net1 y Net2)
deploy-networking: check
	@echo "🚀 Desplegando Módulo de Networking (module.networking)..."
	@terraform apply -auto-approve -target=module.networking
	@echo "🚀 Desplegando Módulo de Networking2 (module.networking2)..."
	@terraform apply -auto-approve -target=module.networking2
	@echo "🚀 Desplegando Módulo de router (module.router)..."
	@terraform apply -auto-approve -target=module.router

# 2. Servidor de Administración (ADMIN)
deploy-admin: check
	@echo "🚀 Desplegando Servidor ADMIN (module.admin_vm)..."
	@terraform apply -auto-approve -target=module.admin_vm

# 3. Servidores Web (S1, S2, S3)
deploy-webservers: check
	@echo "🚀 Desplegando Servidores Web (module.web_s1, module.web_s2, module.web_s3)..."
	@terraform apply -auto-approve -target=module.web

# 4. Base de Datos (BBDD)
deploy-db: check
	@echo "🚀 Desplegando Base de Datos (module.db_bbdd)..."
	@terraform apply -auto-approve -target=module.db_bbdd

# 5. Almacenamiento (Opcional)
deploy-object_storage: check
	@echo "🚀 Desplegando Módulo de Almacenamiento (module.object_storage)..."
	@terraform apply -auto-approve -target=module.object_storage

# 6. Balanceador de Carga (LB)
deploy-loadbalancer: check
	@echo "🚀 Desplegando Módulo de Load Balancer (module.loadbalancer)..."
	@terraform apply -auto-approve -target=module.loadbalancer

# 7. Balanceador de Carga (LB)
deploy-firewall: check
	@echo "🚀 Desplegando Módulo de Firewall (module.firewall)..."
	@terraform apply -auto-approve -target=module.firewall

# ---------------------------------------------------------
# OBJETIVOS ESPECÍFICOS DE DESTRUCCIÓN (Usando -target)
# ---------------------------------------------------------
.PHONY: destroy-networking destroy-loadbalancer destroy-admin destroy-webservers destroy-db destroy-storage destroy-firewall

destroy-networking: init
	@echo "🧨 Destruyendo router y redes (module.router, module.networking2, module.networking)..."
	@terraform destroy -auto-approve -target=module.router
	@terraform destroy -auto-approve -target=module.networking2
	@terraform destroy -auto-approve -target=module.networking
	@echo "✅ Redes destruidas."

destroy-loadbalancer: init
	@echo "🧨 Destruyendo Load Balancer (module.loadbalancer)..."
	@terraform destroy -auto-approve -target=module.loadbalancer
	@echo "✅ Load balancer destruido."

destroy-admin: init
	@echo "🧨 Destruyendo Servidor ADMIN (module.admin_vm)..."
	@terraform destroy -auto-approve -target=module.admin_vm
	@echo "✅ ADMIN destruido."

destroy-webservers: init
	@echo "🧨 Destruyendo servidores web (module.web)..."
	@terraform destroy -auto-approve -target=module.web
	@echo "✅ Webservers destruidos."

destroy-db: init
	@echo "🧨 Destruyendo Base de Datos (module.db_bbdd)..."
	@terraform destroy -auto-approve -target=module.db_bbdd
	@echo "✅ BBDD destruida."

destroy-storage: init
	@echo "🧨 Destruyendo módulo de almacenamiento (module.storage)..."
	@terraform destroy -auto-approve -target=module.storage
	@echo "✅ Storage destruido."

destroy-firewall: init
	@echo "🧨 Destruyendo Firewall (module.firewall)..."
	@terraform destroy -auto-approve -target=module.firewall
	@echo "✅ Firewall destruido."


# ---------------------------------------------------------
# Create graph
# ---------------------------------------------------------
.PHONY: graph extract_key ssh_deny ssh_allow sshAdmin deploy_numb_web_servers

graph:  
	@echo "🖼️  Generando graph.png (terraform graph -> dot)..."
	@python3 generate_graph.py png
	@echo "✅ graph.png creado en $(PWD)/graph.png"


# ---------------------------------------------------------
# KEYS & SSH
# ---------------------------------------------------------
extract_key:
	@echo "🔑 Extrayendo la clave privada del keypair..."
	@terraform output -raw admin_key_private > ./keys/admin_key.pem
	@chmod 600 ./keys/admin_key.pem || true
	@printf 'export admin_ip="%s"\n' "$$(terraform output -raw admin_ssh_ip)" > ./keys/admin_ssh_ip.sh || true
	@echo "✅ Clave privada guardada en ./keys/admin_key.pem"

ssh_deny:
	@echo "🚫 Denegando acceso SSH al servidor ADMIN..."
	@terraform apply -auto-approve -var="actions_ssh_admin=deny"
	@echo "✅ Acceso SSH denegado."

ssh_allow:
	@echo "✅ Permitido acceso SSH al servidor ADMIN..."
	@terraform apply -auto-approve -var="actions_ssh_admin=allow"
	@echo "✅ Acceso SSH permitido."


sshAdmin:
	@echo "🔧 Conectando al servidor ADMIN..."
	@bash -c 'source ./keys/admin_ssh_ip.sh && ssh -p 2025 -i ./keys/admin_key.pem root@$$admin_ip'
	@echo "✅ Acceso SSH configurado."


deploy_numb_web_servers:
	@num=$(filter-out $@,$(MAKECMDGOALS)); \
	if [ -z "$$num" ]; then \
	  if [ -n "$(web_servers_count)" ]; then \
	    num=$(web_servers_count); \
	  else \
	    echo "Uso: make deploy_numb_web_servers 12  (o make deploy_numb_web_servers web_servers_count=12)"; \
	    exit 1; \
	  fi; \
	fi; \
	@echo "🚀 Desplegando $$num servidores web..."; \
	@terraform apply -auto-approve -var="web_servers_count=$$num"; \
	@echo "✅ Despliegue de $$num servidores web completado."

# catch-all para evitar error cuando pasas el número como segundo objetivo
%:
	@:

# ---------------------------------------------------------
# Nodos de openstack
# ---------------------------------------------------------

run_nodes1:
	@/lab/cnvr/bin/get-openstack-tutorial.sh

run_nodes2:
	@echo "Iniciando creación y arranque del laboratorio (run_nodes2)..."
	@cd /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04 && \
	sudo vnx -f openstack_lab.xml --create && \
	sudo vnx -f openstack_lab.xml -x start-all,load-img && \
	sudo vnx_config_nat ExtNet $$(ip route | grep default | cut -d" " -f 5) && \
	sudo vnx -f openstack_lab-terraform.xml --create && \
	sudo vnx -f openstack_lab-terraform.xml -x install-terraform
	@echo "run_nodes2 completado."

run_problem_terraform:
	@echo "Iniciando resolución de problemas de Terraform en el laboratorio..."
	@cd /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04 && \
	sudo vnx -f openstack_lab-terraform.xml -x install-terraform


destroy_nodes:
	@cd /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04 && \
	sudo vnx -f openstack_lab-terraform.xml --destroy
	@cd /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04 && \
	sudo vnx -f openstack_lab.xml --destroy

cp_shared:
	@echo "🔁 Copiando repo a shared excluyendo .git y token..."
	@rsync -a --exclude='.git' --exclude='token' ../terraform_openstack_scenario/ /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04/shared/
	@echo "✅ Copia completada."