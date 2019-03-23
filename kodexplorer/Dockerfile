FROM webdevops/php-nginx:alpine
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

ENV KODEXPLORER_VERSION=4.39

RUN set -ex && \
    apk add --no-cache wget bash && \
    wget -O- https://github.com/kalcaddle/KodExplorer/archive/${KODEXPLORER_VERSION}.tar.gz | tar -xzC /app --strip-components=1 && \
    chmod -R 777 /app/
