#cloud-config
package_update: true
packages:
  - apache2
  - php-cli
  - php-mysql

write_files:
  # Archivo de configuración de Apache
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
          ErrorLog /var/log/apache2/error.log
          CustomLog /var/log/apache2/access.log combined
      </VirtualHost>

runcmd:
  # Instalar PHP 8.3 (opcional)
  - bash -lc 'DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y php8.3-cli php-mysql || true'

  # Crear carpeta web
  - bash -lc 'mkdir -p /var/www/html/miweb || true'

  # Inyectar el archivo tar (base64 desde Terraform) y descomprimir
  - bash -lc 'echo "${tar_file}" | base64 --decode > /tmp/web_files.tar.gz'
  - bash -lc 'tar -xzf /tmp/web_files.tar.gz -C /var/www/html/miweb || true'
  - bash -lc 'chown -R www-data:www-data /var/www/html/miweb || true'

  # Configurar Apache
  - bash -lc 'a2enmod rewrite || true'
  - bash -lc 'a2ensite webPHP.conf || true'

  # Crear drop-in systemd para variables de entorno de la BBDD
  - bash -lc 'mkdir -p /etc/systemd/system/apache2.service.d || true'
  - bash -lc "cat > /etc/systemd/system/apache2.service.d/web_env.conf <<'EOF'
[Service]
Environment='DB_HOST=${db_host}'
Environment='DB_USER=${db_user}'
Environment='DB_PASS=${db_pass}'
Environment='DB_NAME=${db_name}'
EOF"
  - bash -lc 'chmod 600 /etc/systemd/system/apache2.service.d/web_env.conf'
  - bash -lc 'chown root:root /etc/systemd/system/apache2.service.d/web_env.conf'

  # Recargar systemd y reiniciar Apache
  - bash -lc 'systemctl daemon-reload'
  - bash -lc 'systemctl restart apache2 || systemctl reload apache2 || true'
