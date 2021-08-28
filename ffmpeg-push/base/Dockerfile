FROM alpine

RUN apk add --no-cache wget curl ffmpeg tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

COPY --chmod=0755 *.sh /bin

CMD ["/bin/sh", "/bin/entrypoint.sh"]
