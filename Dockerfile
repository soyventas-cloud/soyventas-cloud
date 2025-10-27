# Usa una imagen oficial de PHP con FPM y extensiones recomendadas para Laravel
FROM php:8.2-fpm

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl

# Instala extensiones de PHP requeridas por Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instala Composer
COPY --from=composer:2.5 /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www

# Copia los archivos del proyecto al contenedor
COPY . .

# Instala dependencias de Composer
RUN composer install --no-dev --optimize-autoloader

# Da permisos a la carpeta de almacenamiento y caché
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expone el puerto 9000 y usa el usuario www-data
EXPOSE 9000
USER www-data

# Comando por defecto
CMD ["php-fpm"]
 
