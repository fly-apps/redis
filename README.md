
# Redis

This is the official repository to support Redis on Fly.io. If you need no customizations, you can use the accompanying Docker image
from [flyio/redis](https://hub.docker.com/repository/docker/flyio/redis).

# Customizations

The two `sysctl` calls set up the environment so that Redis doesn't throw warnings about memory and connections. The script then starts up 
the Redis server, giving it a password to require and a directory for persisting data.
## Runtime requirements

By default, this Redis installation will only accept connections on the private IPv6 network, on the standard port 6379.

If you want to access it from the public internet, uncomment the `[[services]]` section in your `fly.toml`. An example is included in this repo with Redis running on port 10000.

This installation requires setting a password on Redis. To do that, run `fly secrets set REDIS_PASSWORD=mypassword` before deploying. Keep
track of this password - it won't be visible again after deployment!

Finally, we need a persistent volume to store Redis data. If you skip this step, data will be lost across deploys or restarts.

For Fly apps, the volume needs to be in the same region as the app instances. We'll give the volume the name `redis_server` in this example.

```cmd
flyctl volumes create redis_server --region ord
```
```out
      Name: redis_server
    Region: ord
   Size GB: 10
Created at: 02 Nov 20 19:55 UTC
```

To connect this volume to the app, `fly.toml` includes a `[[mounts]]` entry.

```
[[mounts]]
source      = "redis_server"
destination = "/data"
```

When the app starts, that volume will be mounted on /data. 

## Deploy

We're ready to deploy now. Run `fly deploy` and the Redis app will be created and launched on the cloud. Once complete you can connect to it using the `redis-cli` command or any other redis client from another application on the internal network.
