
FROM registry.cn-hangzhou.aliyuncs.com/miaowoo/development:alpine AS builder
RUN apk add --no-cache make gcc g++ python3 python3-dev libsecret libsecret-dev curl && ln -sf /usr/bin/python3 /usr/bin/python
ARG version=latest
WORKDIR /home
ADD . .
RUN set -ex && \
    node build.js
WORKDIR /home/theia
RUN cp /home/package.json ./
RUN set -ex && \
    sed -i s@marketplace.visualstudio.com@ms-vscode.gallery.vsassets.io@g package.json && \
    sed -i s@publishers@publisher@g package.json && \
    sed -i s@vsextensions@extension@g package.json && \
    sed -i s@vspackage@assetbyname/Microsoft.VisualStudio.Services.VSIXPackage@g package.json && \
    yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.js.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM registry.cn-hangzhou.aliyuncs.com/miaowoo/development:alpine
LABEL MAINTAINER="MiaoWoo(admin@yumc.pw)"

WORKDIR /home/theia
COPY --from=builder /home/theia /home/theia

ENV THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
EXPOSE 3000
ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
