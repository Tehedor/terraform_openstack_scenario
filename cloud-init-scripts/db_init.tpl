#cloud-config
package_update: true
packages:
  - mysql-server

write_files:
  # Script para inicializar la base de datos mínima
  - path: /root/init-db.sh
    permissions: '0755'
    content: |
      #!/bin/sh
      # Crea la base de datos y el usuario
      mysql -e "CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
      mysql -e "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"
      # mysql ${db_name} < /root/init-data.sql
      # mysql -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';"
      # mysql -e "FLUSH PRIVILEGES;"

  # Configuración ligera de MySQL para VMs con poca RAM
  - path: /etc/mysql/mysql.conf.d/mysqld_small.cnf
    permissions: '0644'
    content: |
      [mysqld]
      innodb_buffer_pool_size = 16M
      key_buffer_size = 4M
      max_connections = 5
      query_cache_size = 0
      table_open_cache = 32
      tmp_table_size = 8M
      max_heap_table_size = 8M
      skip_name_resolve = 1

runcmd:
  # Detener servicios innecesarios para liberar RAM
  - systemctl stop snapd
  - systemctl disable snapd
  - systemctl stop apport
  - systemctl disable apport

  # Configurar bind-address antes de arrancar MySQL
  - sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

  # Arrancar MySQL
  - systemctl enable mysql
  - systemctl start mysql

  # Espera que MySQL esté completamente estable
  - sleep 120

  # Ejecutar inicialización mínima después de que MySQL esté listo
  - /root/init-db.sh
