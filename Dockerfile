FROM redis:alpine

ADD start-redis-server.sh /usr/bin/

CMD ["start-redis-server.sh"]