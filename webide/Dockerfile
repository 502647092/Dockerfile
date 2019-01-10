FROM miaowoo/openjdk:8u181

EXPOSE 8080

RUN set -ex && \
    apk add --no-cache zsh git openssh && \
    git clone --depth=1 git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

ENV SHELL /bin/zsh

ADD webide.tar.gz /root

WORKDIR /root
CMD ["java", "-jar", "ide-backend.jar", "--PTY_LIB_FOLDER=/root/lib"]
