ARG REDIS_VERSION=6.2.6
FROM redis:${REDIS_VERSION}-alpine

ADD start-redis-server.sh /usr/bin/
RUN chmod +x /usr/bin/start-redis-server.sh

CMD ["start-redis-server.sh"]
