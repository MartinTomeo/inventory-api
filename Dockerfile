FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-dev \
    && docker-php-ext-install sqlite3 \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Permitir las reglas de tu .htaccess.
RUN printf '<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>\n' \
    > /etc/apache2/conf-available/api.conf \
    && a2enconf api

WORKDIR /var/www/html

COPY . .

# Las fotos se guardan en el disco persistente.
RUN rm -rf /var/www/html/uploads \
    && ln -s /var/data/uploads /var/www/html/uploads

EXPOSE 80

# Crear carpetas y asignar permisos después de montar el disco.
CMD ["sh", "-c", "mkdir -p /var/data/uploads/users /var/data/uploads/stock && chown -R www-data:www-data /var/data && exec apache2-foreground"]