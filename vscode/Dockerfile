FROM miaowoo/development:alpine

RUN npm install --unsafe-perm -g code-server@3.6.0

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
