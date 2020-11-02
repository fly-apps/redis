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
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024
```