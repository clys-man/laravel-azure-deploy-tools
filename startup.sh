#!/bin/bash

if [ -z "$APP_MAINTENANCE_SECRET" ]; then
    APP_MAINTENANCE_SECRET=$(openssl rand -hex 16)
fi

echo "Maintenance Secret: $APP_MAINTENANCE_SECRET"

php /home/site/wwwroot/artisan down --refresh=15 --secret="$APP_MAINTENANCE_SECRET"

apt-get update && apt-get install -y \
    cron \
    nginx \
    ffmpeg \
    build-essential \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    supervisor

docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp &&
    docker-php-ext-install gd mbstring pdo pdo_mysql zip pcntl sockets bcmath gettext &&
    pecl install redis &&
    docker-php-ext-enable redis

mkdir -p /etc/supervisor.d /run/nginx /var/www /var/log/supervisor /var/log/nginx &&
    touch /run/nginx/nginx.pid /run/supervisord.sock &&
    ln -sf /dev/stdout /var/log/nginx/access.log &&
    ln -sf /dev/stderr /var/log/nginx/error.log

cp ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
cp ./crontab /etc/crontabs/root
cp ./php/php.ini /usr/local/etc/php/conf.d/local.ini
cp ./nginx/conf.d/default.conf /etc/nginx/sites-enabled/default

php /home/site/wwwroot/artisan migrate --force

php /home/site/wwwroot/artisan route:cache
php /home/site/wwwroot/artisan config:cache
php /home/site/wwwroot/artisan view:cache
php /home/site/wwwroot/artisan horizon:terminate

# php /home/site/wwwroot/artisan pulse:restart

# php /home/site/wwwroot/artisan storage:link

# Uncomment the following lines if you want to use Node.js
# npm ci
# npm run production --silent

service nginx restart
service supervisor restart

php /home/site/wwwroot/artisan up
