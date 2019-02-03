FROM alpine:edge

WORKDIR /home/theia
EXPOSE 3000

ADD package.json ./

RUN apk add --no-cache nodejs yarn curl python make gcc g++ go
RUN yarn global add node-gyp && yarn --cache-folder ./ycache && rm -rf ./ycache
RUN set -ex && \
    go get -u -v github.com/ramya-rao-a/go-outline && \
    go get -u -v github.com/acroca/go-symbols && \
    go get -u -v github.com/nsf/gocode && \
    go get -u -v github.com/rogpeppe/godef && \
    go get -u -v golang.org/x/tools/cmd/godoc && \
    go get -u -v github.com/zmb3/gogetdoc && \
    go get -u -v golang.org/x/lint/golint && \
    go get -u -v github.com/fatih/gomodifytags && \
    go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs && \
    go get -u -v golang.org/x/tools/cmd/gorename && \
    go get -u -v sourcegraph.com/sqs/goreturns && \
    go get -u -v github.com/cweill/gotests/... && \
    go get -u -v golang.org/x/tools/cmd/guru && \
    go get -u -v github.com/josharian/impl && \
    go get -u -v github.com/haya14busa/goplay/cmd/goplay && \
    go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct \
    mkdir -p /home/theia/.go && \
    echo '{"toolsGopath":"/home/theia/go"}' > /home/theia/.go/go.json

ENV GOPATH /home/project

ENTRYPOINT [ "yarn", "theia", "start", "/home/project", "--hostname=0.0.0.0" ]
