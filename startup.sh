#!/bin/bash

# apt-get update --allow-releaseinfo-change && apt-get install -y libfreetype6-dev \
#     libjpeg62-turbo-dev \
#     libpng-dev \
#     libwebp-dev &&
#     docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg
# docker-php-ext-install gd

cp /home/default /etc/nginx/sites-enabled/default
cp /home/php.ini /usr/local/etc/php/conf.d/php.ini

# Uncomment the following lines if you want to use Supervisor
# apt-get install -y supervisor
# cp /home/laravel-worker.conf /etc/supervisor/conf.d/laravel-worker.conf

if [ -z "$APP_MAINTENANCE_SECRET" ]; then
    APP_MAINTENANCE_SECRET=$(openssl rand -hex 16)
fi

echo "Maintenance Secret: $APP_MAINTENANCE_SECRET"

php /home/site/wwwroot/artisan down --refresh=15 --secret="$APP_MAINTENANCE_SECRET"

php /home/site/wwwroot/artisan migrate --force

#php /home/site/wwwroot/artisan auth:clear-resets
php /home/site/wwwroot/artisan route:cache
php /home/site/wwwroot/artisan config:cache
php /home/site/wwwroot/artisan view:cache

# php /home/site/wwwroot/artisan horizon:terminate

# php /home/site/wwwroot/artisan pulse:restart

# php /home/site/wwwroot/artisan storage:link

# Uncomment the following lines if you want to use Node.js
# npm ci
# npm run production --silent

service nginx restart
# service supervisor restart

php /home/site/wwwroot/artisan up
