#cloud-config
package_update: true
packages:
  - apache2
  - php-cli
  - php-mysql

# network:
#   version: 2
#   ethernets:
#     eth0:
#       dhcp4: no
#       addresses: [${IP}/24]
#       gateway4: 172.27.47.1
#       nameservers:
#         addresses: [1.1.1.1, 8.8.8.8]

write_files:
  # Archivo de configuración Apache
  - path: /etc/apache2/sites-available/webPHP.conf
    owner: root:root
    permissions: '0644'
    content: |
      <VirtualHost *:80>
          ServerAdmin webmaster@localhost
          DocumentRoot /var/www/html/miweb
          <Directory /var/www/html/miweb>
              Options Indexes FollowSymLinks
              AllowOverride All
              Require all granted
          </Directory>
          ErrorLog ${APACHE_LOG_DIR}/error.log
          CustomLog ${APACHE_LOG_DIR}/access.log combined
      </VirtualHost>

  # Tar.gz con los archivos de la web (base64 inyectado desde Terraform)
  - path: /tmp/web_files.tar.gz
    owner: root:root
    permissions: '0644'
    encoding: gzip
    content: !!binary |
      ${tar_file}

runcmd:
  # Instalar PHP 8.3
  - [ bash, -lc, 'DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y php8.3-cli php-mysql || true' ]
  # Activar mod_rewrite y site
  - [ bash, -lc, 'a2enmod rewrite || true' ]
  - [ bash, -lc, 'a2ensite webPHP.conf || true' ]
  # Crear carpeta de la web y descomprimir
  - [ bash, -lc, 'mkdir -p /var/www/html/miweb || true' ]
  - [ bash, -lc, 'tar -xzf /tmp/web_files.tar.gz -C /var/www/html/miweb || true' ]
  - [ bash, -lc, 'chown -R www-data:www-data /var/www/html/miweb || true' ]

  # Crear drop-in systemd para variables de entorno (DB)
  - [ bash, -lc, 'mkdir -p /etc/systemd/system/apache2.service.d || true' ]
  - [ bash, -lc, 'cat <<EOF > /etc/systemd/system/apache2.service.d/web_env.conf
[Service]
Environment="DB_HOST=${db_host}"
Environment="DB_USER=${db_user}"
Environment="DB_PASS=${db_pass}"
Environment="DB_NAME=${db_name}"
EOF' ]
  - [ bash, -lc, 'chmod 600 /etc/systemd/system/apache2.service.d/web_env.conf' ]
  - [ bash, -lc, 'chown root:root /etc/systemd/system/apache2.service.d/web_env.conf' ]

  # Recargar systemd y reiniciar Apache
  - [ bash, -lc, 'systemctl daemon-reload' ]
  - [ bash, -lc, 'systemctl restart apache2 || systemctl reload apache2 || true' ]
