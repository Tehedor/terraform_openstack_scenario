#!/bin/bash

# =========================================================
# Script de Bash para la Orquestación Modular de Terraform
# Este script replica la funcionalidad del Makefile.
# =========================================================

# --- VARIABLES DE CONFIGURACIÓN ---
# Comando Terraform
TF_COMMAND="terraform"

# Lista de módulos en orden de despliegue lógico
MODULES=(
    "modules/01_networking"
    "modules/02_loadbalancer"
    "modules/03_app_servers"
    "modules/04_admin_server"
    "modules/05_database"
    "modules/06_storage"
)

# ---------------------------------------------------------
# FUNCIONES BÁSICAS DE TERRAFORM
# ---------------------------------------------------------

init() {
    echo "--- 🛠️ Inicializando Terraform en el directorio raíz ---"
    $TF_COMMAND init
}

fmt() {
    echo "--- 📝 Formateando código Terraform recursivamente ---"
    $TF_COMMAND fmt -recursive
}

validate() {
    echo "--- ✅ Validando configuración Terraform en el directorio raíz ---"
    $TF_COMMAND validate
}

clean() {
    echo "--- 🧹 Limpiando archivos temporales ---"
    rm -rf .terraform .terraform.lock.hcl
    echo "Limpieza completada."
}

# ---------------------------------------------------------
# FUNCIÓN UTILITARIA PARA VARIABLES (control_vars)
# ---------------------------------------------------------

control_vars() {
    echo "--- 🧬 Generando temporal_variables.tf con definiciones de módulos ---"
    # El operador > sobrescribe el archivo si existe
    find . -name "variables.tf" -not -path "./temporal_variables.tf" -exec cat {} \; > temporal_variables.tf
    echo "temporal_variables.tf creado. Útil para validadores de IDEs."
}

# ---------------------------------------------------------
# FUNCIONES DE CICLO DE VIDA Y CHEQUEO
# ---------------------------------------------------------

check() {
    init
    fmt
    validate
    control_vars # Ejecuta la utilidad de variables
    echo "✅ Chequeos de código completados satisfactoriamente."
}

# Función genérica para aplicar un módulo específico
deploy_module_template() {
    local module_path="$1"
    echo "--- 🚀 Desplegando el Módulo: ${module_path} ---"
    
    # Entra en el directorio del módulo, inicializa y aplica
    (
        cd "${module_path}" || exit
        $TF_COMMAND init
        $TF_COMMAND apply -auto-approve
    )
    
    if [ $? -eq 0 ]; then
        echo "--- ✅ Módulo ${module_path} Desplegado ---"
    else
        echo "--- ❌ ERROR al desplegar el módulo ${module_path} ---"
        exit 1
    fi
}

deploy_all() {
    check
    echo "=========================================================="
    echo "🌟 INICIANDO DESPLIEGUE SECUENCIAL DE ARQUITECTURA"
    echo "=========================================================="
    
    for module in "${MODULES[@]}"; do
        deploy_module_template "$module"
    done

    echo "=========================================================="
    echo "🎉 ARQUITECTURA COMPLETA DESPLEGADA con éxito."
    echo "=========================================================="
}

destroy_all() {
    echo "=========================================================="
    echo "💥 INICIANDO DESTRUCCIÓN DE TODA LA INFRAESTRUCTURA"
    echo "=========================================================="
    $TF_COMMAND destroy
    echo "=========================================================="
    echo "🗑️  DESTRUCCIÓN FINALIZADA."
    echo "=========================================================="
}

# ---------------------------------------------------------
# FUNCIONES ESPECÍFICAS DE MÓDULOS (Para llamadas individuales)
# ---------------------------------------------------------

# Función genérica para encontrar el path de un módulo por su nombre
get_module_path() {
    local name_part="$1"
    for module_path in "${MODULES[@]}"; do
        if [[ "$module_path" == *"$name_part"* ]]; then
            echo "$module_path"
            return 0
        fi
    done
    return 1
}

deploy_networking() { deploy_module_template $(get_module_path "01_networking"); }
deploy_loadbalancer() { deploy_module_template $(get_module_path "02_loadbalancer"); }
deploy_app_servers() { deploy_module_template $(get_module_path "03_app_servers"); }
deploy_admin_server() { deploy_module_template $(get_module_path "04_admin_server"); }
deploy_database() { deploy_module_template $(get_module_path "05_database"); }
deploy_storage() { deploy_module_template $(get_module_path "06_storage"); }

# ---------------------------------------------------------
# FUNCIÓN DE VIRTUALIZACIÓN (run_nodes)
# ---------------------------------------------------------

run_nodes() {
    echo "--- 💻 Configurando Nodos de OpenStack/VNX ---"
    /lab/cnvr/bin/get-openstack-tutorial.sh
    
    TUTORIAL_PATH="/mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04"
    
    # Usamos subshells y && para garantizar que cada comando se ejecute con éxito
    cd /mnt/tmp/openstack_lab-antelope_4n_classic_ovs-v04 || { echo "Error: Directorio de laboratorio no encontrado."; exit 1; }
    sudo vnx -f openstack_lab.xml --create
    sudo vnx -f openstack_lab.xml -x start-all,load-img
    
    # Obtener la interfaz de red default y configurar NAT (como en el Makefile)
    DEFAULT_IFACE=$(ip route | grep default | cut -d" " -f 5)
    sudo vnx_config_nat ExtNet "$DEFAULT_IFACE"
    
    # Configuración de Terraform
    sudo vnx -f openstack_lab-terraform.xml --create
    sudo vnx -f openstack_lab-terraform.xml -x install-terraform
    
    echo "--- ✅ Nodos de OpenStack/VNX listos y Terraform instalado ---"
}


# ---------------------------------------------------------
# FUNCIÓN PRINCIPAL Y AYUDA
# ---------------------------------------------------------

help() {
    echo "=========================================================="
    echo "          	   AYUDA DE COMANDOS BASH (deploy.sh)"
    echo "=========================================================="
    echo "Uso: ./deploy.sh [comando]"
    echo ""
    echo "Comandos de Ciclo de Vida Compuesto:"
    echo "  check         : Ejecuta 'init', 'fmt', 'validate', y 'control_vars'."
    echo "  deploy_all    : Despliega toda la arquitectura paso a paso."
    echo "  destroy_all   : ELIMINA toda la infraestructura."
    echo ""
    echo "Comandos de Despliegue Modular (Individuales):"
    echo "  deploy_networking   : Despliega solo modules/01_networking"
    echo "  deploy_loadbalancer : Despliega solo modules/02_loadbalancer"
    echo "  deploy_app_servers  : Despliega solo modules/03_app_servers"
    echo "  deploy_admin_server : Despliega solo modules/04_admin_server"
    echo "  deploy_database     : Despliega solo modules/05_database"
    echo "  deploy_storage      : Despliega solo modules/06_storage"
    echo ""
    echo "Comandos Utilitarios:"
    echo "  init          : Inicializa Terraform."
    echo "  fmt           : Formatea el codigo."
    echo "  validate      : Valida la configuracion."
    echo "  clean         : Limpia archivos temporales."
    echo "  control_vars  : Genera el archivo temporal_variables.tf."
    echo "  run_nodes     : Inicializa el entorno OpenStack/VNX."
}

# Lógica de enrutamiento: Llama a la función solicitada
if [ $# -eq 0 ]; then
    help
elif [[ $(type -t "$1") == function ]]; then
    "$@"
else
    echo "❌ Comando no reconocido: $1. Usa ./deploy.sh help para ver las opciones."
    exit 1
fi