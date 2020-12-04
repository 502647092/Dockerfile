FROM registry.cn-hangzhou.aliyuncs.com/miaowoo/development:alpine

RUN npm install --unsafe-perm -g code-server

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
