#!/bin/sh

# Generate SSL key
mkdir -p /var/www/ssl
[ -f /var/www/ssl/cert.pem ] || [ -f /vaw/www/ssl/cert.key ] || openssl req  -batch -new -x509 -days 730 -nodes -out /var/www/ssl/cert.pem -keyout /var/www/ssl/cert.key
[ -f /var/www/ssl/dh2048.pem ] || openssl dhparam -out /var/www/ssl/dh2048.pem 2048
[ -f /var/www/ssl/root.pem ] || ln -s /var/www/ssl/cert.pem /var/www/ssl/root.pem
chmod 600 /etc/nginx/cert.pem
chmod 600 /etc/nginx/cert.key
chmod 600 /etc/nginx/dh2048.pem
chmod 600 /etc/nginx/root.pem

# Start php-fpm
/etc/init.d/php{phpver}-fpm start

# Start redis
/etc/init.d/redis-server start

# Start Nginx
nginx -g "daemon off;"
