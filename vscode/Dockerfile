FROM miaowoo/development:alpine

RUN npm install -g code-server

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
