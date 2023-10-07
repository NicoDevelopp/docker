FROM ubuntu/apache2:latest as http

ENV APACHE_RUN_USER=symfony
ENV APACHE_RUN_GROUP=symfony

ENV PS1="🐋[\e[0;34m\u@\h\e[0m \w]$ "

ENV PHPFPM_PORT=9000

RUN mkdir -p /var/www/html/public

COPY config/apache/default.conf /etc/apache2/sites-available/000-default.conf

RUN sed -i "s/php:9000/php:${PHPFPM_PORT}/g" /etc/apache2/sites-available/000-default.conf


RUN a2enmod rewrite actions alias proxy_fcgi setenvif

RUN cat /etc/apache2/envvars

RUN sed -i "s/www-data/${APACHE_RUN_USER}/g" /etc/apache2/envvars

RUN cat /etc/apache2/envvars

RUN groupadd ${APACHE_RUN_GROUP}

RUN useradd -g ${APACHE_RUN_GROUP} ${APACHE_RUN_USER}

EXPOSE 80 443