FROM alpine:edge
MAINTAINER MiaoWoo<admin@yumc.pw>

ENV LANG C.UTF-8

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u191
ENV JAVA_ALPINE_VERSION 8.191.12-r0

RUN set -x && \
  apk --no-cache add ttf-freefont tzdata ca-certificates openjdk8="$JAVA_ALPINE_VERSION" && \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  rm -rf /var/cache/apk/* && \
  echo "Asia/Shanghai" > /etc/timezone && \
  [ "$JAVA_HOME" = "$(docker-java-home)" ]
