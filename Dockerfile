# Dockerfile para SoyVentas Laravel + PostgreSQL
FROM ubuntu:22.04

# Evitar preguntas durante instalación
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Bogota

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    git \
    unzip \
    nginx \
    supervisor \
    ca-certificates \
    lsb-release \
    gnupg

# Agregar repositorio oficial de PHP
RUN add-apt-repository ppa:ondrej/php -y

# Instalar PHP 8.3 y extensiones necesarias
RUN apt-get update && apt-get install -y \
    php8.3 \
    php8.3-fpm \
    php8.3-common \
    php8.3-mysql \
    php8.3-pgsql \
    php8.3-xml \
    php8.3-curl \
    php8.3-gd \
    php8.3-mbstring \
    php8.3-zip \
    php8.3-bcmath \
    php8.3-intl \
    php8.3-json \
    php8.3-readline \
    php8.3-simplexml \
    php8.3-tokenizer \
    php8.3-xmlreader \
    php8.3-xmlwriter

# Instalar Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Crear directorio de la aplicación
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# Copiar archivos de configuración
COPY .docker/nginx.conf /etc/nginx/sites-available/default
COPY .docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Hacer enlace simbólico para nginx
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
RUN rm -f /etc/nginx/sites-enabled/default

# Configurar PHP-FPM
RUN sed -i 's/;clear_env = no/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf

# Copiar código de la aplicación
COPY . .

# Instalar dependencias de Composer (sin desarrollo)
RUN composer install --no-dev --optimize-autoloader

# Configurar permisos de Laravel
RUN chown -R www-data:www-data /var/www/html/storage
RUN chown -R www-data:www-data /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage
RUN chmod -R 775 /var/www/html/bootstrap/cache

# Exponer puerto
EXPOSE 80

# Comando de inicio
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
