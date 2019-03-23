FROM webdevops/php-nginx
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

ENV KODEXPLORER_VERSION=4.39

RUN set -ex && \
    sed -i s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g /etc/apk/repositories && \
    apk add --no-cache wget bash && \
    wget -O- https://github.com/kalcaddle/KodExplorer/archive/${KODEXPLORER_VERSION}.tar.gz | tar -xzC /app --strip-components=1
