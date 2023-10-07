ARG NODE_VERSION=20

# syntax=docker/dockerfile:1
FROM node:${NODE_VERSION}-alpine AS node

ENV NPM_CONFIG_LOGLEVEL info
# Configure le prompt des utilisateurs
ENV PS1="🐳[\e[0;34m\u@\h\e[0m \w]$ "

RUN apk add --no-cache bash shadow \
    && groupmod --new-name symfony node \
    && usermod --move-home --home /home/symfony --login symfony --shell /bin/bash node

WORKDIR /var/www/html

USER symfony

ENTRYPOINT ["tail", "-f", "/dev/null"]