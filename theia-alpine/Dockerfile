
FROM node:10-alpine AS builder
RUN apk add --no-cache make gcc g++ python
ARG version=latest
WORKDIR /home/theia
ADD package.json ./package.json
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
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM miaowoo/development:alpine
LABEL MAINTAINER="MiaoWoo(admin@yumc.pw)"

WORKDIR /home/theia
COPY --from=builder /home/theia /home/theia
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENV THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
EXPOSE 3000
ENTRYPOINT [ "entrypoint.sh" ]
