ARG PHP_VERSION=8.3

FROM php:${PHP_VERSION}-fpm-alpine as php

ARG UID=1000
ARG GID=1000

ENV PHPUSER=symfony
ENV PHPGROUP=symfony
ENV COMPOSER_HOME /home/${PHPUSER}/.composer

ENV PS1="🐋[\e[0;34m\u@\h\e[0m \w]$ "

ENV LANG=fr_FR.UTF-8
ENV LANGUAGE=fr_FR:fr

RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
    acl \
    bash \
    git \
    rsync \
    shadow \
    tzdata

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN addgroup -g ${GID} --system ${PHPGROUP}
RUN adduser -G ${PHPGROUP} --system -D -s /bin/sh -u ${UID} ${PHPUSER}

RUN curl -sSLf -o /usr/local/bin/install-php-extensions \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

RUN mkdir -p /var/www/html/public && chown -R ${PHPUSER}:${PHPGROUP} /var/www/html

RUN mkdir -p ${COMPOSER_HOME} && chown ${PHPUSER}:${PHPGROUP} ${COMPOSER_HOME}

RUN mkdir -p /var/www/html/var

RUN HTTPDUSER=$(ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1)

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN sed -ri -e 's!;date.timezone =!date.timezone = "Europe/Paris"!g' /usr/local/etc/php/php.ini

RUN install-php-extensions opcache soap pdo_pgsql pdo_mysql intl xdebug apcu zip memcached @composer

COPY config/php/* /usr/local/etc/php/conf.d/

EXPOSE 9000 9003

USER ${PHPUSER}

CMD ["php-fpm"]