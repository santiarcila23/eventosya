FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip libpng-dev \
    libonig-dev libxml2-dev curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN cp .env.example .env

RUN composer install --optimize-autoloader --no-dev --no-interaction --no-scripts

RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD php artisan migrate --force ; apache2-foreground