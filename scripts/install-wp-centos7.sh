#!/bin/bash

# DB, Wordpress 초기비번 정의 /root/INIT_PASSWORD
INIT_ID="thaonv"
INIT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 10)
echo $INIT_PASSWORD > /root/INIT_PASSWORD

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum install yum-utils -y
yum-config-manager --enable remi-php72
yum install -y httpd php mariadb-server php-mysqlnd expect wget

chown -R apache:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb

# DB 비번 초기화 ============================
/usr/bin/mysqladmin -u root password "$INIT_PASSWORD"
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$INIT_PASSWORD\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password\"
send \"$INIT_PASSWORD\r\"
expect \"Re-enter new password\"
send \"$INIT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"

# Mysql 설정 : wordpress DB 생성, User/PW 생성
mysql -u root -p$INIT_PASSWORD mysql -e "\
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON *.* TO '$INIT_ID'@'localhost' IDENTIFIED BY '$INIT_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '$INIT_ID'@'%'  IDENTIFIED BY '$INIT_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;\
"

# Wordpress 설치
mkdir -p /var/www/
pushd /var/www/
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm -f latest.tar.gz
chown -R apache:apache wordpress
mv html{,_old}
mv wordpress html
popd

sed -e "s/database_name_here/"wordpress"/" -e "s/username_here/"$INIT_ID"/" -e "s/password_here/"$INIT_PASSWORD"/" /var/www/html/wp-config-sample.php > /var/www/html/wp-config.php

echo $INIT_ID >> wp-info.txt
echo $INIT_PASSWORD >> wp-info.txt