# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

require 'yaml'

settings = YAML.load_file('settings.yaml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = settings['box'] ||= 'bento/centos-7.2'
  config.vm.hostname = settings['hostname'] ||= 'develop'
  config.vm.network 'forwarded_port', guest: 80, host: 8888, auto_correct: true
  config.vm.network 'private_network', ip: settings['ip'] ||= '192.168.33.10'
  config.vm.synced_folder '.', '/vagrant'

  if settings.has_key?('network')
    config.vm.network 'public_network', ip: settings['network']['ip'], bridge: settings['network']['bridge'] ||= nil
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.name = settings['hostname'] ||= 'develop'
    vb.memory = settings['memory'] ||= '2048'
  end

  config.ssh.forward_agent = true

  config.vm.provision 'file', source: './resources/main.cf', destination: 'main.cf'
  config.vm.provision 'file', source: './resources/httpd.conf', destination: 'httpd.conf'
  config.vm.provision 'file', source: './resources/php.ini', destination: 'php.ini'
  config.vm.provision 'file', source: './resources/logrotate_php', destination: 'logrotate_php'
  config.vm.provision 'file', source: './resources/my.cnf', destination: 'my.cnf'
  config.vm.provision 'file', source: './resources/phpMyAdmin.conf', destination: 'phpMyAdmin.conf'
  config.vm.provision 'file', source: './resources/xdebug.ini', destination: 'xdebug.ini'

  config.vm.provision 'shell' do |s|
    s.path = './bootstrap.sh'
    s.args = [
      settings['db_name'] ||= 'develop',
      settings['db_username'] ||= 'develop',
      settings['db_password'] ||= 'develop',
      settings['ruby_version'] ||= '2.2.4'
    ]
  end

  config.vm.provision 'shell', run: 'always', :inline => <<-SHELL
    if [ -e /var/www/html ]; then
      rm -rf /var/www/html
    fi

    systemctl restart httpd
    systemctl restart mysqld
  SHELL
end
