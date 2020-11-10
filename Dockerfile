FROM redis:alpine

ADD redis.conf /usr/local/etc/redis/redis.conf
ADD start-redis-server.sh /usr/bin/
ADD certs /etc/certs
RUN chmod +x /usr/bin/start-redis-server.sh

CMD ["start-redis-server.sh"]