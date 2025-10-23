FROM php:8.3-fpm

# Install PHP extensions required by InvoicePlane
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev zip unzip curl git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli pdo pdo_mysql mbstring xml intl zip opcache \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Fix permissions for www-data
RUN chown -R www-data:www-data /var/www/html

# Recommended PHP settings (optional)
COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
