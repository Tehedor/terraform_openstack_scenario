#cloud-config
package_update: true
packages:
  - apache2
  - git
  - php
  - php-mysql

write_files:
  - path: /etc/systemd/system/apache2.service.d/web_env.conf
    owner: root:root
    permissions: '0600'
    content: |
      [Service]
      Environment="DB_HOST=${db_host}:3306"
      Environment="DB_USER=${db_user}"
      Environment="DB_PASS=${db_pass}"
      Environment="DB_NAME=${db_name}"
      Environment="PAGE_TITLE=${page_title}"
      Environment="IP_OBJECT_STORAGE=${object_storage_host}"


runcmd:
  # Clonar el repositorio y copiar solo la carpeta phpApp
  - [ bash, -lc, 'rm -f /var/www/html/index.html || true' ]
  - [ bash, -lc, 'mkdir -p /tmp/web_clone && git clone --depth=1 https://github.com/Tehedor/web_php_basica.git /tmp/web_clone' ]
  - [ bash, -lc, 'cp -r /tmp/web_clone/phpApp/* /var/www/html/' ]
  - [ bash, -lc, 'chown -R www-data:www-data /var/www/html' ]

  # Crear drop-in systemd para variables de entorno (DB)
  - [ bash, -lc, 'mkdir -p /etc/systemd/system/apache2.service.d' ]
#   - [ bash, -lc, 'cat <<EOF > /etc/systemd/system/apache2.service.d/web_env.conf
# [Service]
# Environment="DB_HOST=${db_host}:3306"
# Environment="DB_USER=${db_user}"
# Environment="DB_PASS=${db_pass}"
# Environment="DB_NAME=${db_name}"
# Environment="PAGE_TITLE=${page_title}"
# Environment="IP_OBJECT_STORAGE=${object_storage_host}"
# EOF' ]
  - [ bash, -lc, 'chmod 600 /etc/systemd/system/apache2.service.d/web_env.conf' ]
  - [ bash, -lc, 'chown root:root /etc/systemd/system/apache2.service.d/web_env.conf' ]

  # Recargar systemd y reiniciar Apache
  - [ bash, -lc, 'systemctl daemon-reload' ]
  - [ bash, -lc, 'systemctl restart apache2' ]
