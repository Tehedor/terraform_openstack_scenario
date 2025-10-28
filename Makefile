# =========================================================
# Makefile para la Orquestación Modular de Terraform
# Utiliza make help para ver todas las opciones disponibles.
# =========================================================

# Variables: Evita problemas de concurrencia y usa el entorno 'dev' por defecto.
ENV ?= dev
PLAN_FILE := tfplan_$(ENV)
TF_COMMAND := terraform

# Lista de módulos en orden de despliegue lógico (usando los prefijos numéricos)
MODULES := \
	modules/01_networking \
	modules/02_loadbalancer \
	modules/03_app_servers \
	modules/04_admin_server \
	modules/05_database \
	modules/06_storage

.PHONY: help check all deploy-all destroy clean \
	deploy-networking deploy-loadbalancer deploy-app-servers \
	deploy-admin-server deploy-database deploy-storage

# ---------------------------------------------------------
# METAS DE AYUDA Y CHEQUEO (CHECK)
# ---------------------------------------------------------

help:
	@echo "=========================================================="
	@echo "                AYUDA DE COMANDOS MAKEFILE"
	@echo "=========================================================="
	@echo "Comandos de Ciclo de Vida Compuesto:"
	@echo "  make check       : Ejecuta 'init', 'fmt', y 'validate'."
	@echo "  make deploy-all  : Despliega toda la arquitectura paso a paso."
	@echo "  make destroy     : ELIMINA toda la infraestructura (Requiere confirmación)."
	@echo ""
	@echo "Comandos de Despliegue Modular (Individuales):"
	@echo "  make deploy-networking  : Despliega solo módulos/01_networking"
	@echo "  make deploy-loadbalancer: Despliega solo módulos/02_loadbalancer"
	@echo "  make deploy-app-servers : Despliega solo módulos/03_app_servers"
	@echo "  make deploy-admin-server: Despliega solo módulos/04_admin_server"
	@echo "  make deploy-database    : Despliega solo módulos/05_database"
	@echo "  make deploy-storage     : Despliega solo módulos/06_storage"
	@echo ""
	@echo "Comandos Utilitarios:"
	@echo "  make init        : Inicializa Terraform."
	@echo "  make fmt         : Formatea el código."
	@echo "  make validate    : Valida la configuración."
	@echo "  make clean       : Limpia archivos temporales."

check: init fmt validate
	@echo "✅ Chequeos de código completados satisfactoriamente."

# ---------------------------------------------------------
# METAS DE DESPLIEGUE MODULAR (INDIVIDUAL)
# ---------------------------------------------------------

# Función genérica para aplicar un módulo específico
define DEPLOY_MODULE_TEMPLATE
	@echo "--- 🚀 Desplegando el Módulo: $(1) ---"
	cd $(1) && $(TF_COMMAND) init
	cd $(1) && $(TF_COMMAND) apply -auto-approve
	@echo "--- ✅ Módulo $(1) Desplegado ---"
endef

deploy-networking: 
	$(call DEPLOY_MODULE_TEMPLATE, $(filter modules/01_networking, $(MODULES)))

deploy-loadbalancer: 
	$(call DEPLOY_MODULE_TEMPLATE, $(filter modules/02_loadbalancer, $(MODULES)))

deploy-app-servers: 
	$(call DEPLOY_MODULE_TEMPLATE, $(filter modules/03_app_servers, $(MODULES)))

deploy-admin-server: 
	$(call DEPLOY_MODULE_TEMPLATE, $(filter modules/04_admin_server, $(MODULES)))

deploy-database: 
	$(call DEPLOY_MODULE_TEMPLATE, $(filter modules/05_database, $(MODULES)))

deploy-storage: 
	$(call DEPLOY_MODULE_TEMPLATE, $(filter modules/06_storage, $(MODULES)))


# ---------------------------------------------------------
# METAS COMPUESTAS DE CICLO DE VIDA
# ---------------------------------------------------------

# Meta compuesta: Despliega la arquitectura completa en el orden lógico.
# NOTA: En este contexto, cada módulo se aplica individualmente. Si usaras
# solo el 'main.tf' del root, no necesitarías esta secuencia, pero como pediste
# metas individuales, replicamos la secuencia aquí.
deploy-all: check \
	deploy-networking \
	deploy-loadbalancer \
	deploy-app-servers \
	deploy-admin-server \
	deploy-database \
	deploy-storage
	@echo "=========================================================="
	@echo "🎉 ARQUITECTURA COMPLETA DESPLEGADA con éxito."
	@echo "=========================================================="

# Destruye toda la infraestructura
# Se ejecuta el destroy en el directorio raíz para que elimine todos los recursos
# gestionados por todos los módulos referenciados en el main.tf.
destroy:
	@echo "=========================================================="
	@echo "💥 INICIANDO DESTRUCCIÓN DE TODA LA INFRAESTRUCTURA"
	@echo "=========================================================="
	$(TF_COMMAND) destroy
	@echo "=========================================================="
	@echo "🗑️  DESTRUCCIÓN FINALIZADA."
	@echo "=========================================================="

# ---------------------------------------------------------
# METAS BÁSICAS (llamadas por 'check' y otras)
# ---------------------------------------------------------

init:
	$(TF_COMMAND) init

fmt:
	$(TF_COMMAND) fmt -recursive

validate:
	$(TF_COMMAND) validate

clean:
	@echo "--- Limpiando archivos temporales ---"
	rm -f $(PLAN_FILE)
	rm -rf .terraform .terraform.lock.hcl
	@echo "Limpieza completada."

