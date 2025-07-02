#!/bin/bash

# Define Database Password
DATABASE_PASS='admin123'

# Update system packages
yum update -y

# Install dependencies
yum install -y epel-release
yum install -y mariadb-server wget git unzip socat

# Start and enable MariaDB
systemctl start mariadb
systemctl enable mariadb

# Update MariaDB to listen on all interfaces
sed -i 's/^bind-address/#bind-address/' /etc/my.cnf.d/mariadb-server.cnf
sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf

# Restart MariaDB to apply configuration
systemctl restart mariadb

# Secure MariaDB installation and configure database
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p"$DATABASE_PASS" -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"
mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts;"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"

# Restore the database from backup file
cd /tmp/
wget https://raw.githubusercontent.com/devopshydclub/vprofile-repo/vp-rem/src/main/resources/db_backup.sql
mysql -u root -p"$DATABASE_PASS" accounts < /tmp/db_backup.sql

# Install and configure Memcached
yum install -y memcached
systemctl start memcached
systemctl enable memcached
systemctl status memcached

# Install and configure RabbitMQ
yum install -y erlang socat
#!/bin/bash

# Define Database Password
DATABASE_PASS='admin123'

# Update system packages
yum update -y

# Install dependencies
yum install -y epel-release
yum install -y mariadb-server wget git unzip socat

# Start and enable MariaDB
systemctl start mariadb
systemctl enable mariadb

# Update MariaDB to listen on all interfaces
sed -i 's/^bind-address/#bind-address/' /etc/my.cnf.d/mariadb-server.cnf
sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf

# Restart MariaDB to apply configuration
systemctl restart mariadb

# Secure MariaDB installation and configure database
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p"$DATABASE_PASS" -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"
mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts;"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"

# Restore the database from backup file
cd /tmp/
wget https://raw.githubusercontent.com/devopshydclub/vprofile-repo/vp-rem/src/main/resources/db_backup.sql
mysql -u root -p"$DATABASE_PASS" accounts < /tmp/db_backup.sql

# Install and configure Memcached
yum install -y memcached
systemctl start memcached
systemctl enable memcached
systemctl status memcached

# Install and configure RabbitMQ
sudo yum install -y erlang-25.3.2.9-1.el8.x86_64.rpm
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.12.5/rabbitmq-server-3.12.5-1.el8.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
sudo rpm -Uvh rabbitmq-server-3.12.5-1.el8.noarch.rpm

# Start and enable RabbitMQ
systemctl start rabbitmq-server
systemctl enable rabbitmq-server

# Configure RabbitMQ
echo "[{rabbit, [{loopback_users, []}]}]." | sudo tee /etc/rabbitmq/rabbitmq.config
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
sudo systemctl restart rabbitmq-server

# Verification Commands
systemctl status mariadb
systemctl status memcached
systemctl status rabbitmq-server
