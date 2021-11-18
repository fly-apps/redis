
# Redis

This is the official repository to support Redis on Fly.io. If you need no customizations, you can use the accompanying Docker image
from [flyio/redis](https://hub.docker.com/repository/docker/flyio/redis).

# Customizations

The two `sysctl` calls set up the environment so that Redis doesn't throw warnings about memory and connections. The script then starts up 
the Redis server, giving it a password to require and a directory for persisting data.
## Rolling your own

By default, this Redis installation will only accept connections on the private IPv6 network. If you want internet access, uncomment the `[[services]]` section in `fly.toml`. 
## Keeping a secret

Our script takes a password from an environment variable to secure Redis. We need to set that now using the `fly secrets` command. This encrypts the value so it can't leak out; the only time it is decoded is into the Fly application as an environment variable.

```
flyctl secrets set REDIS_PASSWORD=<a password>
```

And of course, remember that password because you won't be able to get it back.
## Persisting Redis

The last step is to create a disk volume for Redis to save its state on. Then the Redis can be restarted without losing data. For Fly apps, the volume needs to be in the same region as the app. We saw that region when we initialized the app; here it's `ord`. We'll give the volume the name `redis_server`. 

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

## Notes

* This configuration sets Redis with mostly default settings. 

## Discuss

* You can discuss this example on the [community.fly.io](https://community.fly.io/t/new-redis-example/366) topic.

