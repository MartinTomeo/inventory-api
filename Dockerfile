FROM php:8.3-apache

# Verificar que SQLite3 esté disponible.
RUN php -r 'if (!extension_loaded("sqlite3") || !class_exists("SQLite3")) { fwrite(STDERR, "SQLite3 no esta disponible\n"); exit(1); } echo "SQLite3 disponible\n";'

# Habilitar las reglas de reescritura.
RUN a2enmod rewrite

# Permitir .htaccess y desactivar el listado de directorios.
RUN printf '%s\n' \
    '<Directory /var/www/html>' \
    '    Options -Indexes +FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    > /etc/apache2/conf-available/api.conf \
    && a2enconf api

# Enviar errores a los logs, sin romper las respuestas JSON.
RUN printf '%s\n' \
    'display_errors=Off' \
    'display_startup_errors=Off' \
    'log_errors=On' \
    'error_reporting=E_ALL' \
    'error_log=/proc/self/fd/2' \
    > /usr/local/etc/php/conf.d/production-errors.ini

WORKDIR /var/www/html

# Copiar el backend, sus dependencias y demo.db.
COPY . .

# Colocar la base inicial fuera del directorio público.
RUN mkdir -p /var/data \
    && mv /var/www/html/data.db /var/data/data.db

# Verificar que la base tenga la tabla users.
RUN php -r '$db = new SQLite3("/var/data/data.db", SQLITE3_OPEN_READONLY); if (!$db->querySingle("SELECT COUNT(*) FROM sqlite_master WHERE type = '\''table'\'' AND name = '\''users'\''")) { fwrite(STDERR, "Falta la tabla users\n"); exit(1); } echo "Base de demostracion lista\n";'

# Configurar las carpetas de imágenes.
RUN mkdir -p /var/data/uploads/users /var/data/uploads/stock \
    && rm -rf /var/www/html/uploads \
    && ln -s /var/data/uploads /var/www/html/uploads \
    && chown -R www-data:www-data /var/data

ENV DB_PATH=/var/data/data.db

EXPOSE 80

CMD ["apache2-foreground"]