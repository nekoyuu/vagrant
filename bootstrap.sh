#!/usr/bin/env bash

# timezone の設定
echo "Setting the TimeZone..."
timedatectl set-timezone Asia/Tokyo

# MySQL と競合するので MariaDB を削除
echo "Deleting MariaDB package..."
yum -y remove mariadb-libs

# locate を利用可能にする
echo "Installing mlocate..."
yum -y install mlocate
updatedb

# リポジトリを追加
if ! locate epel; then
  echo "Adding the epel repository..."
  rpm -Uvh http://ftp.iij.ad.jp/pub/linux/fedora/epel/7/x86_64/e/epel-release-7-7.noarch.rpm
fi

if ! locate remi; then
  echo "Adding the remi repository..."
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
fi

if ! locate mysql56-community; then
  echo "Adding the mysql community repository..."
  rpm -Uvh http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
fi

# Postfix のインストール
# Note: MySQL と依存関係があるため、パッケージを指定しておかないと MySQL のインストールでこける
#       Dependencies: mysql-community-common, mysql-community-libs
echo "Installing Postfix..."
yum -y --nogpgcheck --disablerepo=mysql57-community --enablerepo=epel,mysql56-community install postfix

if [ -e /home/vagrant/main.cf ]; then
  echo "Copying Postfix config file..."
  mv /home/vagrant/main.cf /etc/postfix/main.cf
fi

systemctl enable postfix
systemctl restart postfix

# Apache のインストール
echo "Installing Apache..."

yum -y --nogpgcheck --enablerepo=epel install httpd

if ! [ -e /vagrant/www ]; then
  echo "Making the \"www\" directory..."
  mkdir /vagrant/www
fi

if ! [ -L /var/www ]; then
  echo "Making the \"www\" directory of symbolic link..."
  rm -rf /var/www
  ln -fs /vagrant/www /var/www
fi

if ! [ -e /var/www/public ]; then
  echo "Making the \"public\" directory..."
  mkdir /var/www/public
fi

if [ -e /home/vagrant/httpd.conf ]; then
  echo "Copying Apache config file..."
  mv /home/vagrant/httpd.conf /etc/httpd/conf/httpd.conf
fi

systemctl enable httpd
systemctl restart httpd

# PHP 5.6 のインストール
echo "Installing PHP 5.6..."
yum -y --nogpgcheck --enablerepo=epel,remi,remi-php56 install php php-devel php-opcache php-mbstring php-mcrypt php-gd php-pecl-imagick php-mysqlnd php-pecl-xdebug php-phpunit-PHPUnit php-pear

if [ -e /home/vagrant/php.ini ]; then
  echo "Copying PHP config file..."
  mv /home/vagrant/php.ini /etc/php.ini
fi

if [ -e /home/vagrant/xdebug.ini ]; then
  echo "Copying Xdebug config file..."
  mv /home/vagrant/xdebug.ini /etc/php.d/15-xdebug.ini
fi

echo "Changing a group name of PHP Session storage directory..."
chown -R :vagrant /var/lib/php/session /var/lib/php/wsdlcache

if ! [ -e /var/log/php_errors.log ]; then
  echo "Making the \"php_errors.log\" file..."
  touch /var/log/php_errors.log
fi
chown vagrant:vagrant /var/log/php_errors.log

if [ -e /home/vagrant/logrotate_php ]; then
  echo "Copying rotate config file of php_errors.log..."
  mv /home/vagrant/logrotate_php /etc/logrotate.d/php
fi

systemctl restart httpd

# MySQL 5.6 のインストール
echo "Installing MySQL 5.6..."

MYSQL_SECURE="vagrant"
DB_NAME=$1
DB_USERNAME=$2
DB_PASSWORD=$3

yum -y --nogpgcheck --disablerepo=mysql57-community --enablerepo=mysql56-community install mysql-community-server

if [ -e /home/vagrant/my.cnf ]; then
  echo "Copying MySQL config file..."
  mv /home/vagrant/my.cnf /etc/my.cnf
fi

systemctl enable mysqld
systemctl start mysqld
mysql -e "SHOW DATABASES;" > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Run the \"mysql_secure_installation\"..."
  yum -y install expect

  SECURE_MYSQL=$(expect -c "
    set timeout 10
    spawn mysql_secure_installation
    expect \"Enter current password for root (enter for none):\"
    send \"\r\"
    expect \"Set root password?\"
    send \"\r\"
    expect \"New password:\"
    send \"$MYSQL_SECURE\r\"
    expect \"Re-enter new password:\"
    send \"$MYSQL_SECURE\r\"
    expect \"Remove anonymous users?\"
    send \"\r\"
    expect \"Disallow root login remotely?\"
    send \"\r\"
    expect \"Remove test database and access to it?\"
    send \"\r\"
    expect \"Reload privilege tables now?\"
    send \"\r\"
    expect eof
  ")
  echo "$SECURE_MYSQL"

  yum -y remove expect
fi

echo "Creating the MySQL new database and user..."
mysql -uroot -p$MYSQL_SECURE -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci";
mysql -uroot -p$MYSQL_SECURE -e "GRANT ALL ON \`$DB_NAME\`.* TO '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD'";

systemctl restart mysqld

# phpMyAdmin のインストール
echo "Installing phpMyAdmin..."
yum -y --nogpgcheck --enablerepo=epel,remi,remi-php56 install phpMyAdmin

if [ -e /home/vagrant/phpMyAdmin.conf ]; then
  echo "Copying phpMyAdmin config file..."
  mv /home/vagrant/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf
fi

systemctl restart httpd

# Git のインストール
echo "Installing Git and Gitflow..."
yum -y --nogpgcheck --enablerepo=epel install git gitflow

# rbenv, ruby-build, Ruby, bundler のインストール
RUBY_VERSION=$4
if ! [ -e /usr/local/src/rbenv ]; then
  # 依存パッケージのインストール
  yum -y --nogpgcheck install openssl-devel readline-devel zlib-devel

  # rbenv のインストール
  echo "Installing rbenv..."
  git clone git://github.com/sstephenson/rbenv.git /usr/local/src/rbenv
  echo 'export RBENV_ROOT="/usr/local/src/rbenv"' >> /etc/profile.d/rbenv.sh
  echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
  source /etc/profile.d/rbenv.sh

  # ruby-build のインストール
  echo "Installing ruby-build..."
  git clone git://github.com/sstephenson/ruby-build.git /usr/local/src/rbenv/plugins/ruby-build

  # Ruby のインストール
  echo "Installing Ryby..."
  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION

  # Gem のアップデート, bundler のインストール
  echo "Installing bundler..."
  gem update --system
  gem install bundler
fi

# Composer のインストール
if ! [ -e /usr/local/bin/composer ]; then
  echo "Installing Composer..."
  php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer
fi

# nvm, Node.js, npm のインストール
if ! [ -e /usr/local/src/nvm ]; then
  # 依存パッケージのインストール
  # libpng-devel は npm の imagemin-pngquant をコンパイルするのに必要っぽい
  yum -y --nogpgcheck install gcc-c++ openssl-devel libpng-devel

  #nvm のインストール
  echo "Installing nvm..."
  git clone git://github.com/creationix/nvm.git /usr/local/src/nvm
  . /usr/local/src/nvm/nvm.sh
  echo 'source /usr/local/src/nvm/nvm.sh' >> /etc/profile.d/nvm.sh

  # node のインストール
  echo "Installing node..."
  nvm install stable
  nvm use stable

  # sudo node, sudo npm が使えるようにする
  echo "Setting node and npm..."
  echo 'Defaults !secure_path' >> /etc/sudoers.d/00_base
  echo 'Defaults env_keep += "PATH RBENV_ROOT"' >> /etc/sudoers.d/00_base
fi

# Sass のインストール
which sass > /dev/null 2>&1
if ! [ $? = 0 ]; then
  echo "Installing Sass..."
  gem install sass
fi

# Compass のインストール
which compass > /dev/null 2>&1
if ! [ $? = 0 ]; then
  echo "Installing Compass..."
  gem install compass
fi

# Bourbon のインストール
which bourbon > /dev/null 2>&1
if ! [ $? = 0 ]; then
  echo "Installing Bourbon..."
  gem install bourbon
fi

# Modular Scale のインストール
if ! locate modular-scale; then
  echo "Installing Modular Scale..."
  gem install modular-scale
fi

# Susy のインストール
if ! locate susy; then
  echo "Installing Susy..."
  gem install susy
fi

# Bower のインストール
which bower > /dev/null 2>&1
if ! [ $? = 0 ]; then
  echo "Installing Bower..."
  npm install -g bower
fi

# Gulp のインストール（npm）
which gulp > /dev/null 2>&1
if ! [ $? = 0 ]; then
  echo "Installing gulp-cli..."
  npm install -g gulp-cli
fi
