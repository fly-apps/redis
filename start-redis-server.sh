#!/bin/sh
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024

MAXMEMORY=${FLY_VM_MEMORY_MB:-512}
MAXMEMORY="$(((($FLY_VM_MEMORY_MB*10)-$FLY_VM_MEMORY_MB)/10))"

redis-server --requirepass $REDIS_PASSWORD --dir /data/ --save 60 1000 --maxmemory "${MAXMEMORY}mb"
