ARG REDIS_VERSION=6.2.6
FROM redis:${REDIS_VERSION}-alpine

WORKDIR /

RUN apk add --no-cache curl
RUN curl -L https://github.com/oliver006/redis_exporter/releases/download/v1.31.4/redis_exporter-v1.31.4.linux-amd64.tar.gz -o exporter.tgz \
  && tar xvzf exporter.tgz \
  && cp redis_exporter-*/redis_exporter /usr/local/bin/redis_exporter \
  && rm -rf *exporter*

RUN curl -L https://github.com/DarthSim/hivemind/releases/download/v1.0.6/hivemind-v1.0.6-linux-amd64.gz -o hivemind.gz \
  && gunzip hivemind.gz \
  && mv hivemind /usr/local/bin

COPY start-redis-server.sh /usr/bin/start-redis-server.sh
COPY Procfile Procfile
RUN chmod +x /usr/bin/start-redis-server.sh /usr/local/bin/hivemind

CMD ["/usr/local/bin/hivemind"]
