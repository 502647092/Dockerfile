FROM miaowoo/development:ubuntu

WORKDIR /home/theia
ADD package.json ./package.json
RUN yarn --cache-folder ./ycache && rm -rf ./ycache

# Add Lombok Support
RUN mkdir -p /home/theia/java && \
  wget -qO/home/theia/java/lombok.jar https://projectlombok.org/downloads/lombok.jar && \
  sed -i s@\'-j@\'-javaagent:/home/theia/java/lombok.jar\',\'-j@g /home/theia/node_modules/@theia/java/src/node/java-contribution.ts && \
  sed -i s@\'-j@\'-javaagent:/home/theia/java/lombok.jar\',\'-j@g /home/theia/node_modules/@theia/java/lib/node/java-contribution.js

# using "NODE_OPTIONS=..." to avoid out-of-memory problem in CI
RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    rm -rf ./node_modules/electron && \
    yarn cache clean

EXPOSE 3000
ENV SHELL /bin/zsh

ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
