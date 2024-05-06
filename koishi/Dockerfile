FROM node:18-alpine3.18
LABEL MAINTAINER="MiaoWoo(admin@yumc.pw)"

RUN apk add --no-cache yarn chromium nss freetype harfbuzz ca-certificates ttf-freefont font-noto-cjk

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME ["/koishi"]
WORKDIR "/koishi"
ENTRYPOINT ["/entrypoint.sh"]
CMD ["yarn", "start"]
