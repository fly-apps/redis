```sh
➜  redis flyctl apps create redis-example

Selected App Name: redis-example

? Select organization: Demo Sandbox (demo-sandbox)

? Select builder: Dockerfile
    (Do not set a builder and use the existing Dockerfile)
? Select Internal Port: 6379

New app created
  Name         = redis-example
  Organization = demo-sandbox
  Version      = 0
  Status       =
  Hostname     = <empty>

Wrote config file fly.toml
➜  redis code .
```

```
flyctl secrets set REDIS_PASSWORD=<a password>
```

```
✗ flyctl volumes create redis_server --region ord
      Name: redis_server
    Region: ord
   Size GB: 10
Created at: 02 Nov 20 19:55 UTC
```

`start-redis-server.sh` sets sysctl parameters and passes the `$REDIS_PASSWORD` environment variable to the process.
```sh
#!/bin/sh
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024
redis-server --requirepass $REDIS_PASSWORD --bind 0.0.0.0 --dir /data/
```