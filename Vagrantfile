# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

require 'yaml'

settings = YAML.load_file('settings.yaml')

if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
  puts '--- ERROR ---'
  puts 'This Vagrantfile is not compatible with Windows environment'
  puts 'exit program...'
  exit
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vagrant.plugins = ['vagrant-vbguest', 'vagrant-bindfs']

  config.vm.box = settings['box'] ||= 'bento/centos-7'
  config.vm.hostname = settings['hostname'] ||= 'develop'
  config.vm.network 'forwarded_port', guest: 80, host: 8888, auto_correct: true
  config.vm.network 'forwarded_port', id: 'ssh', guest: 22, host: 2222, auto_correct: true
  config.vm.network 'private_network', ip: settings['ip'] ||= '10.0.0.100'
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/vagrant-nfs', type: 'nfs'

  config.bindfs.bind_folder '/vagrant-nfs', '/vagrant'

  if settings.has_key?('network')
    config.vm.network 'public_network',
      ip: settings['network']['ip'] ||= '192.168.0.100',
      bridge: settings['network']['bridge'] ||= nil
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.name = settings['hostname'] ||= 'develop'
    vb.memory = settings['memory'] ||= '2048'
  end

  config.ssh.forward_agent = true

  config.vm.provision 'file', source: './resources', destination: 'resources'

  config.vm.provision 'shell' do |s|
    s.path = './bootstrap.sh'
    s.args = [
      settings['db_name'] ||= 'develop',      # $1
      settings['db_username'] ||= 'develop',  # $2
      settings['db_password'] ||= 'develop',  # $3
    ]
  end

  # vagrant ユーザーとして実行
  config.vm.provision 'shell', privileged: false, path: "./anyenv/anyenv.sh"
  config.vm.provision 'shell', privileged: false, path: "./anyenv/envs_install.sh"
  config.vm.provision 'shell', privileged: false do |s|
    s.path = './anyenv/envs.sh'
    s.args = [
      settings['ruby_version'] ||= '3.0.0',    # $1
      settings['node_version'] ||= '15.12.0',  # $2
    ]
  end

  config.vm.provision 'shell', run: 'always', :inline => <<-SHELL
    if [ -d /var/www/html ]; then
      rm -rf /var/www/html
    fi

    systemctl restart httpd
    systemctl restart mysqld
  SHELL
end
