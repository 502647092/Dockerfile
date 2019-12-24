FROM node:10-alpine
LABEL MAINTAINER="MiaoWoo(admin@yumc.pw)"

# Java alpine default install at /usr/lib/jvm/default-jvm
ENV JAVA_HOME=/usr/lib/jvm/default-jvm \
    # Golang alpine default install at /usr/lib/go
    GOROOT=/usr/lib/go \
    GOPATH=/home/theia/go \
    PATH=$PATH:${GOROOT}/bin:${GOPATH}/bin \
    SHELL=/bin/zsh

##GO
#Required to use go get with git source
RUN apk add --no-cache \
    # Base Package
    git ttf-freefont tzdata ca-certificates \
    zsh tmux nano bash tzdata openssh openssl curl inotify-tools \
    # Build tools
    make g++ libx11-dev libxkbfile-dev libsecret libsecret-dev \
    # Go
    go musl-dev \
    # Java
    openjdk8 maven gradle \
    # Python
    python python-dev py-pip \
    # PHP \
    php php7-xml php7-zip php7-dom \
    php-json php-phar php7-zlib php7-curl \
    php7-gd php7-ctype php-iconv php-openssl php-mbstring \
    php7-fileinfo php7-simplexml php7-xmlwriter php7-xmlreader php7-tokenizer

# Python
RUN pip install python-language-server autopep8 pylint

# PHP
RUN curl -s -o composer-setup.php https://getcomposer.org/installer \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && rm composer-setup.php

RUN set -ex && \
    # install VS Code Go tools: https://github.com/microsoft/vscode-go/blob/e0cb5d3a2a/src/goTools.ts#L132-L289
    go get -u -v \
    github.com/mdempsky/gocode \
    github.com/uudashr/gopkgs/cmd/gopkgs \
    github.com/ramya-rao-a/go-outline \
    github.com/acroca/go-symbols \
    golang.org/x/tools/cmd/guru \
    golang.org/x/tools/cmd/gorename \
    github.com/fatih/gomodifytags \
    github.com/haya14busa/goplay/cmd/goplay \
    github.com/josharian/impl \
    github.com/tylerb/gotype-live \
    github.com/rogpeppe/godef \
    github.com/zmb3/gogetdoc \
    golang.org/x/tools/cmd/goimports \
    github.com/sqs/goreturns \
    winterdrache.de/goformat/goformat \
    golang.org/x/lint/golint \
    github.com/cweill/gotests/... \
    honnef.co/go/tools/... \
    github.com/golangci/golangci-lint/cmd/golangci-lint \
    github.com/mgechev/revive \
    github.com/sourcegraph/go-langserver \
    golang.org/x/tools/gopls \
    github.com/go-delve/delve/cmd/dlv \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    github.com/godoctor/godoctor && \
    go get -u -v -d github.com/stamblerre/gocode && \
    go build -o $GOPATH/bin/gocode-gomod github.com/stamblerre/gocode && \
    rm -rf $GOPATH/src && \
    rm -rf $GOPATH/pkg

# Install Tmux Config & On-My-ZSH
RUN set -ex && \
    mkdir ~/.tmux && \
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    wget -qO- https://raw.githubusercontent.com/502647092/Dockerfile/master/development/tmux.conf > ~/.tmux.conf && \
    ~/.tmux/plugins/tpm/bin/install_plugins && \
    git clone --depth=1 git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    sed -i s@ZSH_THEME=\"robbyrussell\"@ZSH_THEME=\"ys\"@g ~/.zshrc && \
    echo 'alias tmux="tmux -u"' >> ~/.zshrc && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone
