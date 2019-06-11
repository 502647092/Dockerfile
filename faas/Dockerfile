FROM node:8.16.0-alpine
LABEL container="MiaoWoo(admin@yumc.pw)"

RUN set -ex &&\
    apk --no-cache add curl \
    && echo "Pulling watchdog binary from Github." \
    && curl -sSL https://github.com/openfaas/faas/releases/download/$(curl -sI https://github.com/openfaas/faas/releases/latest | grep Location | awk -F"/" '{ printf "%s", $NF }' | tr -d '\r')/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl \
    && rm -rf /var/cache/apk/*
