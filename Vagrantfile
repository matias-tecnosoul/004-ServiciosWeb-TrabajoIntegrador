# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  # Red y puertos
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "public_network"
  
  # Recursos
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 4
  end
  
  # Hostname
  config.vm.hostname = "redmine-server"
  
  # Provisioning inicial
  config.vm.provision "shell", inline: <<-SHELL
    set -ex
    
    # Update system
    apt-get update
    apt-get upgrade -y
    
    # Dependencias del sistema (SIN Ruby del sistema)
    apt-get install -y curl git build-essential zlib1g-dev libssl-dev \
      libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev \
      libffi-dev libgdbm-dev libncurses5-dev automake libtool bison \
      pkg-config sqlite3 libsqlite3-dev imagemagick libmagickwand-dev \
      mysql-server mysql-client libmysqlclient-dev nginx software-properties-common \
      apt-transport-https ca-certificates gnupg lsb-release zsh nmap mc
    
    # Crear usuario redmine
    adduser --system --group --home /opt/redmine --shell /bin/bash redmine
    
    # Configurar MySQL
    systemctl enable mysql
    systemctl start mysql
    
    # Configuración segura básica de MySQL
    mysql -e "CREATE DATABASE redmine_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -e "CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'redmine_password';"
    mysql -e "GRANT ALL PRIVILEGES ON redmine_production.* TO 'redmine'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    
    # Instalar asdf para usuario redmine (compatible con bash y zsh)
    sudo -u redmine bash -c '
      git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
      
      # Configurar para bash
      echo ". ~/.asdf/asdf.sh" >> ~/.bashrc
      echo ". ~/.asdf/completions/asdf.bash" >> ~/.bashrc
      
      # Configurar para zsh si existe
      if [ -f ~/.zshrc ] || command -v zsh >/dev/null 2>&1; then
        touch ~/.zshrc
        echo ". ~/.asdf/asdf.sh" >> ~/.zshrc
        echo ". ~/.asdf/completions/asdf.bash" >> ~/.zshrc
      fi
    '
    
  SHELL
end