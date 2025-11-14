#cloud-config
package_update: true
packages:
  - mysql-server
  - git

write_files:
  - path: /root/init-db.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      mysql -e "CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
      mysql ${db_name} < /tmp/web_clone/mysql/init-data.sql
      mysql -e "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"
      mysql -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';"
      mysql -e "FLUSH PRIVILEGES;"

runcmd:
  - mkdir -p /tmp/web_clone
  - git clone https://github.com/Tehedor/web_php_basica.git /tmp/web_clone
  - systemctl enable mysql
  - systemctl start mysql
  - sleep 5
  - bash /root/init-db.sh
  - sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
  - systemctl restart mysql
