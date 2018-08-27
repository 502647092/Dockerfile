FROM alpine:edge
MAINTAINER MiaoWoo<admin@yumc.pw>

ENV LANG C.UTF-8

RUN apk --update add socat

ENV SOCAT_PORT=2376
ENV SOCAT_SOCKET=/var/run/docker.sock

CMD socat -d -d TCP-L:${SOCAT_PORT},fork UNIX:${SOCAT_SOCKET}
