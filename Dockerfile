FROM php:8.3-apache

# Verificar que SQLite3 esté disponible.
RUN php -r 'if (!extension_loaded("sqlite3") || !class_exists("SQLite3")) { fwrite(STDERR, "SQLite3 no esta disponible\n"); exit(1); } echo "SQLite3 disponible\n";'

# Habilitar las reglas de reescritura de Apache.
RUN a2enmod rewrite

# Permitir el uso de tu archivo .htaccess.
RUN printf '%s\n' \
    '<Directory /var/www/html>' \
    '    Options -Indexes +FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    > /etc/apache2/conf-available/api.conf \
    && a2enconf api

WORKDIR /var/www/html

# Copiar el backend y sus dependencias.
COPY . .

# Mantener las URLs /uploads/... usando almacenamiento persistente.
RUN rm -rf /var/www/html/uploads \
    && ln -s /var/data/uploads /var/www/html/uploads

EXPOSE 80

# Preparar las carpetas cuando el disco ya esté montado
# y luego iniciar Apache.
CMD ["sh", "-c", "mkdir -p /var/data/uploads/users /var/data/uploads/stock && chown -R www-data:www-data /var/data && exec apache2-foreground"]