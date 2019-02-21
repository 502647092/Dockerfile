FROM alpine:3.9

WORKDIR /root

RUN mkdir -p /usr/local/bin
ADD build-caddy-file /usr/local/bin/build-caddy-file
ADD caddy caddy
RUN chmod +x /usr/local/bin/build-caddy-file

CMD build-caddy-file > Caddyfile && ./caddy
