#!/usr/bin/env bash
set -euo pipefail

KEY="./keys/admin_key.pem"
IPFILE="./keys/admin_ssh_ip.sh"
USER="${1:-root}"
PORT="${2:-2025}"

if [ ! -f "$KEY" ]; then
  echo "Error: clave privada no encontrada en $KEY" >&2
  exit 1
fi

if [ ! -f "$IPFILE" ]; then
  echo "Error: fichero de IP no encontrado en $IPFILE" >&2
  exit 1
fi

# Cargar admin_ip (export admin_ip="x.x.x.x")
# shellcheck disable=SC1091
source "$IPFILE"

if [ -z "${admin_ip:-}" ]; then
  echo "Error: admin_ip no está definido en $IPFILE" >&2
  exit 1
fi

chmod 600 "$KEY" || true

echo "Conectando a ${USER}@${admin_ip}:${PORT} ..."
ssh -i "$KEY" -p "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${admin_ip}"