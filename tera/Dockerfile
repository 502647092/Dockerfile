FROM node:10.15.3-alpine
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

ENTRYPOINT ["/sbin/tini", "--"]

RUN set -x && \
  apk add --no-cache tini python tzdata && \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  rm -rf /var/cache/apk/* && \
  echo "Asia/Shanghai" > /etc/timezone && \
  wget https://gitlab.com/terafoundation/tera/-/archive/master/tera-master.tar.gz && \
  tar -xvzf tera-master.tar.gz && \
  rm -rf tera-master.tar.gz && \
  mv tera-master /app

WORKDIR /app/Source
RUN npm install

ENV PORT 80
ENV PASSWD 123456
EXPOSE 80

CMD node set httpport:${PORT} password:${PASSWD} && node run-node.js
