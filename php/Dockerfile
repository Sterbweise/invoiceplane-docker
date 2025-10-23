FROM php:8.1-fpm

# Install dependencies and PHP extensions required by InvoicePlane
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    default-mysql-client \
    unzip \
    wget \
    curl \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql mbstring xml intl zip opcache \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /var/www/html

# Ensure the web root belongs to the www-data user
RUN chown -R www-data:www-data /var/www/html

COPY env-to-config.sh /docker-entrypoint-init.d/env-to-config.sh
RUN chmod +x /docker-entrypoint-init.d/env-to-config.sh

ENV INVOICEPLANE_BASE_URL=""
