FROM miaowoo/node-tini:8.15.0-alpine
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

RUN set -x && \
  apk add --no-cache python tzdata && \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  rm -rf /var/cache/apk/* && \
  echo "Asia/Shanghai" > /etc/timezone && \
  wget https://gitlab.com/terafoundation/tera/-/archive/master/tera-master.tar.gz && \
  tar -xvzf tera-master.tar.gz && \
  rm -rf tera-master.tar.gz && \
  mv tera-master /app

WORKDIR /app/Source
RUN yarn

ENV PORT 80
ENV PASSWD 123456
EXPOSE 80

CMD node set httpport:${PORT} password:${PASSWD} && node run-node.js
