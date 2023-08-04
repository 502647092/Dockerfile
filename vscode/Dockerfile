FROM registry.cn-hangzhou.aliyuncs.com/miaowoo/development:alpine

RUN npm install --global code-server --unsafe-perm

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
CMD ["code-server"]
