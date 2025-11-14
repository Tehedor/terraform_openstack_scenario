#cloud-config
package_update: true
packages:
  - mysql-server

write_files:
  # Script para inicializar la base de datos
  - path: /root/init-db.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      mysql -e "CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
      mysql ${db_name} < /root/init-data.sql
      mysql -e "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"
      mysql -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';"
      mysql -e "FLUSH PRIVILEGES;"

  # Datos de ejemplo
  - path: /root/init-data.sql
    permissions: '0755'
    content: |
      SET NAMES utf8;
      SET FOREIGN_KEY_CHECKS = 0;

      -- -------------------------------------------------
      -- Estructura de tabla para la tabla `usuarios`
      -- -------------------------------------------------
      DROP TABLE IF EXISTS `usuarios`;
      CREATE TABLE IF NOT EXISTS `usuarios` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `username` varchar(255)  NOT NULL,
          `email` varchar(255)  NOT NULL,
          PRIMARY KEY (`id`)
      ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

      -- ----------------------------
      --  Registros `usuarios`
      -- ----------------------------
      INSERT INTO `usuarios` (`username`, `email`) VALUES
      ('user', 'user@gmail.com'),
      ('admin', 'admin@gmail.com');

  # Configuración ligera para MySQL (evita que OOM killer lo mate)
  - path: /etc/mysql/mysql.conf.d/mysqld_small.cnf
    permissions: '0644'
    content: |
      [mysqld]
      innodb_buffer_pool_size = 32M
      key_buffer_size = 8M
      max_connections = 10
      query_cache_size = 0
      table_open_cache = 64
      tmp_table_size = 16M
      max_heap_table_size = 16M

runcmd:
  # Configura bind-address antes de arrancar MySQL
  - sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
  # Habilita y arranca MySQL
  - systemctl enable mysql
  - systemctl start mysql
  - sleep 10
  # Ejecuta script de inicialización
  - bash /root/init-db.sh
