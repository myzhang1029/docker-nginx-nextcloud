# Image with Nginx and php-fpm
FROM debian:latest
LABEL maintainer="Zhang Maiyun <myzhang1029@hotmail.com>"
 
#ARG APT_MIRROR="mirrors.bfsu.edu.cn"
ARG PHP_VER="7.3"

# Set up APT
#RUN sed -i "s/httpredir.debian.org/${APT_MIRROR}/g" /etc/apt/sources.list
#RUN sed -i "s/security.debian.org/${APT_MIRROR}/g" /etc/apt/sources.list
#RUN sed -i "s/deb.debian.org/${APT_MIRROR}/g" /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

RUN usermod -a -G www-data www-data

RUN apt-get install -y nginx openssl ssl-cert php${PHP_VER}-xml php${PHP_VER}-dev php${PHP_VER}-curl php${PHP_VER}-gd php${PHP_VER}-fpm php${PHP_VER}-zip php${PHP_VER}-intl php${PHP_VER}-mbstring php${PHP_VER}-cli php${PHP_VER}-mysql php${PHP_VER}-common php${PHP_VER}-cgi php${PHP_VER}-apcu php${PHP_VER}-redis php${PHP_VER}-json php${PHP_VER}-mbstring php${PHP_VER}-zip php${PHP_VER}-pgsql php${PHP_VER}-bz2 php${PHP_VER}-imagick redis-server php-pear curl libapr1 libtool libcurl4-openssl-dev libxml2

# Set up Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY nextcloud /etc/nginx/sites-enabled/nextcloud
COPY nextcloud /etc/nginx/sites-available/nextcloud
RUN rm -f /etc/nginx/sites-enabled/default

# Make a link to the SSL keys so one can mount to /var/www/ssl
RUN ln -s /var/www/ssl/cert.pem /etc/nginx/cert.pem
RUN ln -s /var/www/ssl/cert.key /etc/nginx/cert.key
RUN ln -s /var/www/ssl/dh2048.pem /etc/nginx/dh2048.pem
RUN ln -s /var/www/ssl/root.pem /etc/nginx/root.pem
COPY docker-start.sh /docker-start.sh
RUN sed -i s/{phpver}/${PHP_VER}/ /docker-start.sh
RUN chmod +x /docker-start.sh

# Set up php-fpm configurations
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 4096M/" /etc/php/${PHP_VER}/fpm/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 4096M/" /etc/php/${PHP_VER}/fpm/php.ini
RUN sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/${PHP_VER}/fpm/php.ini
RUN sed -i 's/\;env\[HOSTNAME\] = $HOSTNAME/env[HOSTNAME] = $HOSTNAME/' /etc/php/${PHP_VER}/fpm/pool.d/www.conf
RUN sed -i "s,\;env\[PATH\] = /usr/local/bin:/usr/bin:/bin,env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin," /etc/php/${PHP_VER}/fpm/pool.d/www.conf
RUN sed -i "s,\;env\[TMP\] = /tmp,env[TMP] = /tmp," /etc/php/${PHP_VER}/fpm/pool.d/www.conf
RUN sed -i "s,\;env\[TMPDIR\] = /tmp,env[TMPDIR] = /tmp," /etc/php/${PHP_VER}/fpm/pool.d/www.conf
RUN sed -i "s,\;env\[TEMP\] = /tmp,env[TEMP] = /tmp," /etc/php/${PHP_VER}/fpm/pool.d/www.conf

EXPOSE 80
EXPOSE 443

## Entrypoint
CMD ["/docker-start.sh"]

