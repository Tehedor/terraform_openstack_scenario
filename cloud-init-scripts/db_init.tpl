#cloud-config
package_update: true
packages:
  - mysql-server
  - git

runcmd:
  # Clonar el repositorio con el script SQL
  - [ bash, -lc, 'mkdir -p /tmp/web_clone && git clone --depth=1 https://github.com/Tehedor/web_php_basica.git /tmp/web_clone' ]

  # Iniciar el servicio MySQL
  - [ bash, -lc, 'systemctl enable mysql && systemctl start mysql' ]

  # Esperar unos segundos a que MySQL esté completamente iniciado
  - [ bash, -lc, 'sleep 5' ]

  # Crear la base de datos usando la variable de Terraform
  - [ bash, -lc, 'mysql -e "CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"' ]

  # Cargar los datos iniciales desde el SQL del repositorio
  - [ bash, -lc, 'mysql ${db_name} < /tmp/web_clone/mysql/init-data.sql' ]

  # Crear un usuario de aplicación con permisos usando variables de Terraform
  - [ bash, -lc, 'mysql -e "CREATE USER IF NOT EXISTS '\''${db_user}'\''@'\''%'\'' IDENTIFIED BY '\''${db_pass}'\'';"' ]
  - [ bash, -lc, 'mysql -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '\''${db_user}'\''@'\''%'\'';"' ]
  - [ bash, -lc, 'mysql -e "FLUSH PRIVILEGES;"' ]

  # Habilitar conexiones remotas
  - [ bash, -lc, 'sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf' ]
  - [ bash, -lc, 'systemctl restart mysql' ]
