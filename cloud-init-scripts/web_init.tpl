#cloud-config
package_update: true
packages:
  - apache2
  - git
  - php8.3-cli
  - php-mysql

runcmd:
  # Clonar el repositorio y copiar la app
  - [ bash, -lc, 'mkdir -p /tmp/web_clone && git clone --depth=1 https://github.com/Tehedor/web_php_basica.git /tmp/web_clone' ]
  - [ bash, -lc, 'cp -r /tmp/web_clone/phpApp/* /var/www/html/' ]
  - [ bash, -lc, 'chown -R www-data:www-data /var/www/html' ]
  - [ bash, -lc, 'chmod -R 755 /var/www/html' ]

  # Crear drop-in systemd para inyectar variables de entorno de BD
  - [ bash, -lc, 'mkdir -p /etc/systemd/system/apache2.service.d' ]
  - [ bash, -lc, 'cat <<EOF > /etc/systemd/system/apache2.service.d/env.conf
[Service]
Environment="DB_HOST=${db_host}"
Environment="DB_USER=${db_user}"
Environment="DB_PASS=${db_pass}"
Environment="DB_NAME=${db_name}"
EOF' ]
  - [ bash, -lc, 'chmod 600 /etc/systemd/system/apache2.service.d/env.conf' ]
  - [ bash, -lc, 'chown root:root /etc/systemd/system/apache2.service.d/env.conf' ]

  # Recargar y reiniciar Apache
  - [ bash, -lc, 'systemctl daemon-reload' ]
  - [ bash, -lc, 'systemctl restart apache2' ]
