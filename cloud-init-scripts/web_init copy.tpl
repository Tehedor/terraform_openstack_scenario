#cloud-config
package_update: true
packages:
  - apache2
  - git
  - php8.3-cli
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

# write_files:
#   # Archivo de configuración Apache
#   - path: /etc/apache2/sites-available/webPHP.conf
#     owner: root:root
#     permissions: '0644'
#     content: |
#       <VirtualHost *:80>
#           ServerAdmin webmaster@localhost
#           DocumentRoot /var/www/html/miweb
#           <Directory /var/www/html/miweb>
#               Options Indexes FollowSymLinks
#               AllowOverride All
#               Require all granted
#           </Directory>
#           ErrorLog /var/log/apache2/error.log
#           CustomLog /var/log/apache2/access.log combined
#       </VirtualHost>

runcmd:
  # Agregar el PPA de PHP y actualizar repositorios
  - [ bash, -lc, 'add-apt-repository -y ppa:ondrej/php' ]
  - [ bash, -lc, 'apt-get update' ]

  # Instalar PHP 8.3 y módulos necesarios
  - [ bash, -lc, 'DEBIAN_FRONTEND=noninteractive apt-get install -y php8.3 php8.3-cli php8.3-mysql libapache2-mod-php8.3' ]

  # Activar mod_rewrite y sitio web
  - [ bash, -lc, 'a2enmod rewrite || true' ]
  - [ bash, -lc, 'a2ensite webPHP.conf || true' ]
  - [ bash, -lc, 'a2dissite 000-default.conf || true' ]

  # Clonar el repositorio y copiar SOLO phpApp
  - [ bash, -lc, 'mkdir -p /tmp/web_clone && git clone --depth=1 https://github.com/Tehedor/web_php_basica.git /tmp/web_clone' ]
  - [ bash, -lc, 'mkdir -p /var/www/html/miweb' ]
  - [ bash, -lc, 'cp -r /tmp/web_clone/phpApp/* /var/www/html/miweb/' ]
  - [ bash, -lc, 'chown -R www-data:www-data /var/www/html/miweb' ]
  - [ bash, -lc, 'chmod -R 755 /var/www/html/miweb' ]

  # Crear drop-in systemd para variables de entorno (DB)
  - [ bash, -lc, 'mkdir -p /etc/systemd/system/apache2.service.d' ]
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
  - [ bash, -lc, 'systemctl restart apache2' ]

  # Limpieza opcional del clon
  - [ bash, -lc, 'rm -rf /tmp/web_clon_]()
