FROM alpine:edge
MAINTAINER MiaoWoo<admin@yumc.pw>

ENV LANG C.UTF-8

RUN wget -O/root/isl https://github.com/502647092/Dockerfile/raw/master/isl/IntelliJIDEALicenseServer_linux_amd64 && chmod 755 /root/isl

CMD ['/root/isl']
