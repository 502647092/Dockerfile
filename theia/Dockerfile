FROM miaowoo/development:ubuntu

WORKDIR /home/theia

ADD package.json ./package.json

RUN yarn --cache-folder ./ycache && rm -rf ./ycache && \
    mkdir -p /home/theia/plugins && \
    # using "NODE_OPTIONS=..." to avoid out-of-memory problem in CI
    yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

EXPOSE 3000
ENV SHELL=/bin/zsh \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins

ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
