FROM alpine AS builder
WORKDIR /root
RUN apk add jq curl
RUN set -ex \
    && VERSION=`curl -qs https://api.github.com/repos/nadoo/glider/releases/latest | jq -r .name` \
    && wget -O- https://github.com/nadoo/glider/releases/download/${VERSION}/glider_${VERSION:1}_linux_amd64.tar.gz | tar -xzC . --strip-components=1

FROM alpine
LABEL MAINTAINER="MiaoWoo(admin@yumc.pw)"

WORKDIR /root
COPY --from=builder /root/glider /usr/bin/glider
RUN chmod a+x /usr/bin/glider

ENTRYPOINT ["glider"]
