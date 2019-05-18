FROM alpine:edge
LABEL maintainer="MiaoWoo<admin@yumc.pw>"

ENV LANG C.UTF-8

RUN wget -O/root/kms https://github.com/502647092/Dockerfile/raw/master/kms/kms-server && chmod 755 /root/kms

CMD /root/kms
