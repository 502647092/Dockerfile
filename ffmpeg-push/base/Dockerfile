# DOCKER_BUILDKIT=1 docker build -t miaowoo/ffmpeg-push-base:v2.1 .
FROM alpine

RUN apk add --no-cache wget curl ffmpeg tzdata axel && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

COPY --chmod=0755 *.sh /bin

CMD ["/bin/sh", "/bin/entrypoint.sh"]
