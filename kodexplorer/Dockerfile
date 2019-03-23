FROM php:fpm-alpine
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

ENV KODEXPLORER_VERSION=4.39

RUN set -ex && \
    apk add --no-cache wget bash && \
    wget https://github.com/kalcaddle/KodExplorer/archive/${KODEXPLORER_VERSION}.tar.gz | tar -xzf -C /var/www/html
