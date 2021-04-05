#!/usr/bin/env bash

# locale の設定
localedef -f UTF-8 -i ja_JP ja_JP
localectl set-locale LANG=ja_JP.utf8
source /etc/locale.conf

# timezone の設定
echo "Setting the TimeZone..."
timedatectl set-timezone Asia/Tokyo

# locate を利用可能にする
echo "Installing mlocate..."
yum -y install mlocate
updatedb

# MySQL と競合するので MariaDB を削除
if locate mariadb-libs; then
  echo "Deleting MariaDB package..."
  yum -y remove mariadb-libs
fi

# notify-send を利用可能にする（デスクトップ通知）
which notify-send > /dev/null 2>&1
if ! [ $? = 0 ]; then
  echo "Installing notify-send..."
  yum -y install libnotify
fi

# リポジトリを追加
if ! locate epel; then
  echo "Adding the epel repository..."
  yum -y install epel-release
fi

if ! locate remi; then
  echo "Adding the remi repository..."
  rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
fi

if ! locate mysql57-community; then
  echo "Adding the mysql community repository..."
  rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
fi

# zip, unzip のインストール
echo "Installing zip, unzip..."
yum -y --nogpgcheck install zip unzip

# expect のインストール
echo "Installing expect..."
yum -y install expect

# Postfix + SASL のインストール
# Note: MySQL と依存関係があるため、パッケージを指定しておかないと MySQL のインストールでこける
#       Dependencies: mysql-community-common, mysql-community-libs
echo "Installing Postfix + SASL..."
yum -y --nogpgcheck --disablerepo=mysql80-community --enablerepo=epel,mysql57-community install postfix cyrus-sasl*

if [ -e /home/vagrant/resources/postfix/main.cf ]; then
  echo "Copying Postfix config file..."
  mv /home/vagrant/resources/postfix/main.cf /etc/postfix
  chown root:root /etc/postfix/main.cf
fi

if [ -e /home/vagrant/resources/postfix/relay_password ]; then
  echo "Copying sasl relay password file..."
  mv /home/vagrant/resources/postfix/relay_password /etc/postfix
  chown root:root /etc/postfix/relay_password
  postmap hash:/etc/postfix/relay_password
fi

systemctl enable postfix
systemctl restart postfix

# ImageMagick のインストール
# 7 系は rmagick がインストールできないので 6系を入れる
echo "Installing ImageMagick 6.*..."
yum -y --nogpgcheck --enablerepo=remi install ImageMagick6 ImageMagick6-devel

# Apache, OpenSSLのインストール
echo "Installing Apache..."
yum -y --nogpgcheck --enablerepo=epel install httpd httpd-devel openssl-devel mod_ssl

if ! [ -d /vagrant/www ]; then
  echo "Making the \"www\" directory..."
  mkdir /vagrant/www
fi

if ! [ -L /var/www ]; then
  echo "Making the \"www\" directory of symbolic link..."
  rm -rf /var/www
  ln -fs /vagrant/www /var/www
fi

if ! [ -d /var/www/public ]; then
  echo "Making the \"public\" directory..."
  mkdir /var/www/public
fi

if [ -e /home/vagrant/resources/apache/httpd.conf ]; then
  echo "Copying Apache config file..."
  mv /home/vagrant/resources/apache/httpd.conf /etc/httpd/conf
fi

if ! [ -d /etc/pki/tls/certs ]; then
  echo "Making the \"certs\" directory..."
  mkdir /etc/pki/tls/certs
fi

if ! [ -f /etc/pki/tls/certs/server.key -a -f /etc/pki/tls/certs/server.csr ]; then
  echo "Setting the SSL..."
  cd /etc/pki/tls/certs
  openssl genrsa -out server.key 2048

  expect -c "
    spawn openssl req -new -key server.key -out server.csr
    expect \"Country Name\"
    send \"JP\r\"
    expect \"State or Province Name\"
    send \"Tokushima\r\"
    expect \"Locality Name\"
    send \"Tokushima\r\"
    expect \"Organization Name\"
    send \"shape DESIGN\r\"
    expect \"Organizational Unit Name\"
    send \"\r\"
    expect \"Common Name\"
    send \"shape-design.jp\r\"
    expect \"Email Address\"
    send \"info@shape-design.jp\r\"
    expect \"A challenge password\"
    send \"\r\"
    expect \"An optional company name\"
    send \"\r\"
    expect eof
  "

  openssl x509 -req -days 3650 -signkey server.key -in server.csr -out server.crt

  echo "Copying SSL config file..."
  mv /home/vagrant/resources/apache/ssl.conf /etc/httpd/conf.d/ssl.conf
fi

# perl-CGI のインストール
yum -y --nogpgcheck install perl-CGI

systemctl enable httpd
systemctl restart httpd

# PHP 7.4.* のインストール
echo "Installing PHP 7.4..."
yum -y --nogpgcheck --enablerepo=epel,remi,remi-php74 install php php-devel php-opcache php-mbstring php-mcrypt php-gd php-pecl-imagick php-mysqlnd php-pecl-xdebug

echo "Changing a group name of PHP lib directory..."
chown -R vagrant:vagrant /var/lib/php/*

if [ -e /home/vagrant/resources/php/php.ini ]; then
  echo "Copying PHP config file..."
  mv /home/vagrant/resources/php/php.ini /etc
fi

if [ -e /home/vagrant/resources/php/xdebug.ini ]; then
  echo "Copying Xdebug config file..."
  mv /home/vagrant/resources/php/xdebug.ini /etc/php.d/15-xdebug.ini
fi

if [ -e /home/vagrant/resources/php/imagick.ini ]; then
  echo "Copying Imagick config file..."
  mv /home/vagrant/resources/php/imagick.ini /etc/php.d/40-imagick.ini
fi

if ! [ -e /var/log/php_errors.log ]; then
  echo "Making the \"php_errors.log\" file..."
  touch /var/log/php_errors.log
fi
chown vagrant:vagrant /var/log/php_errors.log

if [ -e /home/vagrant/resources/php/logrotate_php ]; then
  echo "Copying rotate config file of php_errors.log..."
  mv /home/vagrant/resources/php/logrotate_php /etc/logrotate.d/php
fi

systemctl restart httpd

# MySQL 5.7 のインストール
echo "Installing MySQL 5.7..."

MYSQL_SECURE="FK7w!Zov3m"
DB_NAME=$1
DB_USERNAME=$2
DB_PASSWORD=$3

yum -y --nogpgcheck --disablerepo=mysql80-community --enablerepo=mysql57-community install mysql-community-server

if [ -e /home/vagrant/resources/mysql/my.cnf ]; then
  echo "Copying MySQL config file..."
  mv /home/vagrant/resources/mysql/my.cnf /etc
fi

if [ -e /home/vagrant/resources/mysql/mysql-clients.cnf ]; then
  echo "Copying MySQL config file..."
  mv /home/vagrant/resources/mysql/mysql-clients.cnf /etc/my.cnf.d
fi

systemctl enable mysqld
systemctl start mysqld

mysql -uroot -p${MYSQL_SECURE} -e "SHOW DATABASES;" > /dev/null 2>&1

if ! [ $? = 0 ]; then
  # 初期パスワードを変更
  # https://akamist.com/blog/archives/1088
  MYSQL_TEMP_PASSWORD=$(grep "A temporary password is generated" /var/log/mysqld.log | sed -s 's/.*root@localhost: //')
  mysql -uroot -p${MYSQL_TEMP_PASSWORD} --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_SECURE}'; FLUSH PRIVILEGES;"

  # デフォルトでインストールされている Password Validation Plugin をアンインストール
  # http://thr3a.hatenablog.com/entry/20160229/1456727388
  mysql -uroot -p${MYSQL_SECURE} -e "UNINSTALL PLUGIN validate_password;"

  echo "Creating the MySQL new database and user..."
  mysql -uroot -p${MYSQL_SECURE} -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
  mysql -uroot -p${MYSQL_SECURE} -e "GRANT ALL ON \`${DB_NAME}\`.* TO '${DB_USERNAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
fi

systemctl restart mysqld

# phpMyAdmin のインストール
echo "Installing phpMyAdmin..."
yum -y --nogpgcheck --enablerepo=epel,remi,remi-php74 install phpMyAdmin

if [ -e /home/vagrant/resources/phpmyadmin/phpMyAdmin.conf ]; then
  echo "Copying phpMyAdmin httpd config file..."
  mv /home/vagrant/resources/phpmyadmin/phpMyAdmin.conf /etc/httpd/conf.d
fi

if [ -e /home/vagrant/resources/phpmyadmin/config.inc.php ]; then
  echo "Copying phpMyAdmin config file..."
  mv /home/vagrant/resources/phpmyadmin/config.inc.php /etc/phpMyAdmin
  chown -R vagrant:vagrant /etc/phpMyAdmin
fi

systemctl restart httpd

# Composer のインストール
if ! [ -e /usr/local/bin/composer ]; then
  echo "Installing Composer..."
  php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer
fi

# Git のインストール
echo "Installing Git and Gitflow..."
yum -y --nogpgcheck --enablerepo=epel install git gitflow

# rbenv で Ruby のインストールに必要
yum -y --nogpgcheck install openssl-devel readline-devel zlib-devel

# Laravel mix で使用する Imagemin プラグイン mozjpeg のインストールに必要
yum -y --nogpgcheck install nasm
