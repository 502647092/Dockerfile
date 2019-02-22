FROM miaowoo/node-tini:8.15.0-alpine
LABEL maintainer="admin@yumc.pw(MiaoWoo)"

RUN apk add git python
RUN git clone https://gitlab.com/terafoundation/tera.git /app

WORKDIR /app/Source
RUN yarn

EXPOSE 8080

CMD node set httpport:${PORT} password:${PASSWD} && node run-node.js
