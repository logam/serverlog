# Use a base image with Alpine Linux and PHP 8
FROM php:8.0.11-fpm-alpine

# Instalar pacotes necessários
RUN apk update && apk add --no-cache \
    nginx \
    libzip-dev \
    zip \
    unzip

# Instalar pacotes necessários para o PostgreSQL
RUN apk add --no-cache postgresql-dev

# Configurar extensão do PHP para o PostgreSQL
RUN docker-php-ext-configure pgsql --with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo_pgsql pgsql


# Instalar módulos PDO para acesso a dados
RUN docker-php-ext-install pdo_mysql pdo_pgsql

# Instalar módulos necessários para o Adianti Framework
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .build-deps

# Copiar configuração do PHP
COPY php.ini /usr/local/etc/php/

# Copiar configuração do Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Criar diretório para os arquivos fonte e configuração do web server
RUN mkdir -p /var/www/html

# Definir diretório de trabalho
WORKDIR /var/www/html

# Expor a porta 80 para acesso HTTP
EXPOSE 80

# Iniciar o serviço do PHP-FPM e Nginx
CMD ["sh", "-c", "php-fpm && nginx -g 'daemon off;'"]
