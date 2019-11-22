FROM node:10.15.3-alpine AS builder

RUN set -x && \
  apk add --no-cache python tzdata make g++ && \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  rm -rf /var/cache/apk/* && \
  echo "Asia/Shanghai" > /etc/timezone && \
  mkdir -p /app && \
  wget -O- https://gitlab.com/terafoundation/tera2/-/archive/master/tera-master.tar.gz | tar -xzC /app --strip-components=1 && \
  cd /app/Source && npm install

FROM node:10.15.3-alpine
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

ENTRYPOINT ["/sbin/tini", "--"]

RUN set -x && \
  apk add --no-cache tini tzdata && \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  rm -rf /var/cache/apk/*

COPY --from=builder /app/Source /app/Source

WORKDIR /app/Source

ENV PORT 80
ENV PASSWD 123456

EXPOSE 80

CMD node set httpport:${PORT} password:${PASSWD} && node run-node.js
