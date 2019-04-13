
FROM node:10-alpine
RUN apk add --no-cache make gcc g++ python
ARG version=latest
WORKDIR /home/theia
ADD package.json ./package.json
RUN yarn --pure-lockfile && \
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
COPY --from=0 --chown=theia:theia /home/theia /home/theia

RUN chmod g+rw /home && \
    mkdir -p /home/project && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/project && \
    rm -rf ~/.theia && \
    mkdir -p /home/project/.theia && \
    ln -sf /home/project/.theia ~/.theia

ENV THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
EXPOSE 3000
ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
