#!/bin/sh
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024
redis-server --requirepass $REDIS_PASSWORD --bind 0.0.0.0 --dir /data/ --appendonly yes