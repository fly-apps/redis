FROM redis:alpine

ADD start-redis-server.sh /usr/bin/
RUN chmod +x /usr/bin/start-redis-server.sh

CMD ["start-redis-server.sh"]