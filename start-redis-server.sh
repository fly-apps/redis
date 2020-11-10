#!/bin/sh
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024

# pass env vars as server args
redis-server /usr/local/etc/redis/redis.conf --requirepass $REDIS_PASSWORD