#!/bin/bash
set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos como usuario redmine
if [ "$(whoami)" != "redmine" ]; then
    log_error "Este script debe ejecutarse como usuario redmine"
    log_info "Ejecuta: sudo -u redmine -i"
    exit 1
fi

log_info "=== Instalando Ruby via asdf ==="

# Cargar asdf
source ~/.asdf/asdf.sh

# Instalar plugin de Ruby
asdf plugin add ruby
asdf plugin add nodejs  # Requerido para assets

# Obtener versión Ruby recomendada para Redmine
# Según documentación: Ruby 2.7, 3.0, 3.1 o 3.2
# Ubuntu 22.04 funciona perfectamente con Ruby 3.2
RUBY_VERSION="3.2.5"
NODE_VERSION="20.17.0"  # Versión más reciente LTS

log_info "Instalando Ruby $RUBY_VERSION..."
asdf install ruby $RUBY_VERSION
asdf global ruby $RUBY_VERSION

log_info "Instalando Node.js $NODE_VERSION..."
asdf install nodejs $NODE_VERSION
asdf global nodejs $NODE_VERSION

# Verificar instalación
ruby -v
gem -v
node -v

log_info "=== Descargando Redmine ==="

cd /opt/redmine

# Descargar última versión estable de Redmine
REDMINE_VERSION="5.1.3"  # Verificar última versión en redmine.org
wget "https://www.redmine.org/releases/redmine-${REDMINE_VERSION}.tar.gz"
tar -xzf "redmine-${REDMINE_VERSION}.tar.gz"
mv "redmine-${REDMINE_VERSION}" redmine
cd redmine

log_info "=== Configurando Base de Datos MySQL ==="

# Crear configuración de base de datos
cat > config/database.yml << EOF
production:
  adapter: mysql2
  database: redmine_production
  host: localhost
  username: redmine
  password: "redmine_password"
  port: 3306
  encoding: utf8mb4
  collation: utf8mb4_unicode_ci
  
development:
  adapter: mysql2
  database: redmine_development
  host: localhost
  username: redmine
  password: "redmine_password"
  port: 3306
  encoding: utf8mb4
  collation: utf8mb4_unicode_ci
EOF

log_info "=== Configurando Redmine ==="

# Copiar configuración por defecto
cp config/configuration.yml.example config/configuration.yml

log_info "=== Instalando Gems ==="

# Instalar bundler
gem install bundler

# Instalar dependencias sin grupos de desarrollo y test
bundle config set --local deployment 'true'
bundle config set --local without 'development test'
bundle install

log_info "=== Configurando Base de Datos ==="

# Generar secret token
bundle exec rake generate_secret_token

# Crear tablas de BD
RAILS_ENV=production bundle exec rake db:migrate

# Cargar datos por defecto
RAILS_ENV=production REDMINE_LANG=es bundle exec rake redmine:load_default_data

log_info "=== Configurando Puma ==="

# Crear configuración de Puma
cat > config/puma.rb << EOF
#!/usr/bin/env puma

# Entorno
environment ENV.fetch('RAILS_ENV', 'production')

# Threads y workers
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
threads threads_count, threads_count

# Bind en todas las interfaces para poder usar con nginx
bind 'tcp://0.0.0.0:3000'

# PID file
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Permitir restart
plugin :tmp_restart

# Workers para producción
workers ENV.fetch('WEB_CONCURRENCY', 2)

# Preload app para mejor performance
preload_app!

# Worker timeout
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'production') == 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  ActiveRecord::Base.establish_connection
end
EOF

log_info "=== Configurando permisos ==="

# Asegurar permisos correctos
chmod -R 755 files log tmp public/plugin_assets
chmod -R 755 .

log_info "=== Compilando Assets ==="

# Compilar assets para producción
RAILS_ENV=production bundle exec rake assets:precompile

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_success "¡Instalación de Redmine completada!"
log_info "Siguiente paso: configurar nginx y systemd"