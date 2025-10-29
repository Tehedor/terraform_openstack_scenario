.PHONY: fmt validate init clean check destroy_all deploy_all

fmt:
	@echo "📝 Formateando código Terraform..."
	@terraform fmt -recursive

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
	@echo "🌟 INICIANDO DESPLIEGUE COMPLETO DE ARQUITECTURA"
	@terraform apply -auto-approve
	@echo "🎉 ARQUITECTURA COMPLETA DESPLEGADA con éxito."

# ---------------------------------------------------------
# OBJETIVOS ESPECÍFICOS DE DESPLIEGUE (Usando -target)
# ---------------------------------------------------------

.PHONY: deploy-networking deploy-loadbalancer deploy-admin deploy-webservers deploy-db deploy-storage

# 1. Redes (Net1 y Net2)
deploy-networking: check
	@echo "🚀 Desplegando Módulo de Networking (module.networking)..."
	@terraform apply -auto-approve -target=module.networking

# 2. Balanceador de Carga (LB)
deploy-loadbalancer: check
	@echo "🚀 Desplegando Módulo de Load Balancer (module.loadbalancer)..."
	@terraform apply -auto-approve -target=module.loadbalancer

# 3. Servidor de Administración (ADMIN)
deploy-admin: check
	@echo "🚀 Desplegando Servidor ADMIN (module.admin_vm)..."
	@terraform apply -auto-approve -target=module.admin_vm

# 4. Servidores Web (S1, S2, S3)
deploy-webservers: check
	@echo "🚀 Desplegando Servidores Web (module.web_s1, module.web_s2, module.web_s3)..."
	@terraform apply -auto-approve -target=module.web_s1 -target=module.web_s2 -target=module.web_s3

# 5. Base de Datos (BBDD)
deploy-db: check
	@echo "🚀 Desplegando Base de Datos (module.db_bbdd)..."
	@terraform apply -auto-approve -target=module.db_bbdd

# 6. Almacenamiento (Opcional)
deploy-storage: check
	@echo "🚀 Desplegando Módulo de Almacenamiento (module.storage)..."
	@terraform apply -auto-approve -target=module.storage

# ---------------------------------------------------------
# DESTRUCCIÓN ESPECÍFICA
# ---------------------------------------------------------

.PHONY: destroy-db

destroy-db: 
	@echo "🗑️  Destruyendo solo el Servidor de Base de Datos..."
	@terraform destroy -auto-approve -target=module.db_bbdd




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


destroy_nodes:
	@cd /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04 && \
	sudo vnx -f openstack_lab-terraform.xml --destroy
	@cd /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04 && \
	sudo vnx -f openstack_lab.xml --destroy

cp_shared:
	@cp -r ../terraform_openstack_scenario/. /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04/shared/