FROM alpine:3.9
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

WORKDIR /root
RUN apk add git && mkdir -p /root/www

COPY entrypoint.sh caddy /usr/local/bin/

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "caddy", "--conf", "/etc/caddy/Caddyfile", "--log", "stdout"]
