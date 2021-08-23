 FROM alpine AS builder
 WORKDIR /root
 RUN apk add jq curl
 RUN set -ex \
     && VERSION=`curl -qs https://api.github.com/repos/Mrs4s/go-cqhttp/releases/latest | jq -r .name` \
     && wget -O- https://github.com/Mrs4s/go-cqhttp/releases/download/${VERSION}/go-cqhttp_linux_amd64.tar.gz | tar -xvzC /root

FROM alpine
LABEL MAINTAINER="MiaoWoo(admin@yumc.pw)"

WORKDIR /root
COPY --from=builder /root/go-cqhttp /usr/bin/go-cqhttp
RUN apk add --no-cache ffmpeg tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    chmod a+x /usr/bin/go-cqhttp

ENTRYPOINT ["go-cqhttp"]
