
# Redis

Deploying Redis using Fly.

<!---- cut here --->

## Rationale

A key/value database like Redis is useful to have to support caching, session management and, well, anything which needs simple fast storage. That's why there's Redis already built into Fly. But there are some things that Redis configuration doesn't do, like Publish and Subscribe, and that's when you want to deploy your own Redis on Fly.

For this example, we are going to customize a Redis docker image to tune it for running on Fly and deploy it with persistent disk storage for Redis to save its data on.

## Preparing

There's a couple of components to this example. We're going to use the official Redis image, `redis:alpine`, but we want to change some system settings before Redis starts running. To do that, we'll use a script, `start-redis-server.sh`

```shell
#!/bin/sh
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024

# pass env vars as server args
redis-server /usr/local/etc/redis/redis.conf --requirepass $REDIS_PASSWORD
```

This sets the VM system settings to Redis recommended values.

It then starts up the Redis server, giving it a password to require and a config file to boot with. The Redis config is simple – it defines IPs to listen on, persistence options:

```conf
# listen on all ipv4 and ipv6 addresses
bind 0.0.0.0 ::

# write to /data/
dir /data/

# appendonly settings
appendonly yes
auto-aof-rewritepercentage 100
auto-aof-rewrite-min-size 64mb
```

Now we need to make those changes apply to a new Redis deployment. For that we use this `Dockerfile`:

```dockerfile
FROM redis:alpine

ADD redis.conf /usr/local/etc/redis/redis.conf
ADD start-redis-server.sh /usr/bin/
ADD certs /etc/certs
RUN chmod +x /usr/bin/start-redis-server.sh

CMD ["start-redis-server.sh"]
```

It adds our new shell script to the image, makes it executable, adds the redis config, and boots the container with the shell script.

With these two files in place we're ready to put Redis onto Fly.

## Configuring

First, we need a configuration file - and a slot on Fly - for our new application. We'll use the `fly init` command. The parameter is the app name we want - names have to be unique so choose a new unique one or omit the name in the command line and let Fly choose a name for you.

```cmd
fly init redis-example
```
```out
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

App will initially deploy to ord (Chicago, Illinois (US)) region

Wrote config file fly.toml
```

The important choices here are we select a Dockerfile (the one we created) as the builder for this app and we set the internal port to 6379, the default port for Redis. Do take note of which region here the init command says the app will initially deploy into. We'll need that in a moment.

This will generate a new fly.toml file which we'll need to edit. By default, the `fly.toml` takes the internal port and connects it to an HTTP only handler on port 80 and a combined TLS/HTTP handler on port 443. We don't need that at all, we just need a straight-through connection to the internal port. 

Edit your generated `fly.toml`, removing both `[[services.ports]]` entries for ports 80 and 443 and replacing them with a single entry:

```
  [[services.ports]]
    handlers = []
    port = "10000"
```

This will direct external traffic on port 10000 to internal port 6379. Save the file for now.

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

To connect this volume to the app, pop back to editing fly.toml and add:

```
[[mounts]]
source      = "redis_server"
destination = "/data"
```

When the app starts, that volume will be mounted on /data.

## Deploy
We're ready to deploy now. Run `fly deploy` and the Redis app will be created and launched on the cloud. Once complete you can connect to it using the `redis-cli` command or any other redis client.  Just remember to use port 10000, not the default port.

```
redis-cli -h redis-example.fly.dev \
          -p 10000 \
          --askpass
```

## Lock it down with TLS

So far, our Redis configuration is good for a demo. But running Redis on a public port with password authentication is insecure.

Redis has built in TLS support, we generate certificates and configure the server to require client certificate validation. This is roughly the equivalent security level as running behind a VPN.

Generating certs is simple with the excellent [`mkcert`](https://github.com/FiloSottile/mkcert) utility. Once you install `mkcert`, you'll get a local certificate authority to create your own certificates with.

Here are the commands you'll need to create certificates for this Redis example:

1. Create `certs` directory for the Docker image:
  
    `mkdir -p certs`
2. Generate server certificates:

   `mkcert -key-file certs/redis-server.key -cert-file certs/redis-server.crt redis-example.fly.dev`
3. Generate a client certificate:

    `mkcert --client -key-file redis-client.key -cert-file redis-client.crt redis-example.fly.dev`
4. Copy the root CA certificate:

    `cp "$(mkcert -CAROOT)/rootCA.pem" certs/rootCA.crt`

When you're done you should see a directory layout like this:

* `/certs`
    * `/redis-server.crt`
    * `/redis-server.key`
    * `/rootCA.crt`
* `/redis-client.crt`
* `/redis-client.key`

Then, we can pop on into the `redis.conf` to configure TLS:

```conf
tls-port 7379
tls-cert-file /etc/certs/server.pem
tls-key-file /etc/certs/server-key.pem
tls-ca-cert-file /etc/certs/rootCA.crt
```

This configures Redis to listen on port 7379, which means updating the internal port in `fly.toml`:

```toml
[[services]]
internal_port = 7379
...
```

Now run `fly deploy` again, and enjoy the relaxation of a locked down Redis service.

The `redis-cli` CLI has support for TLS, you can connect with this command:

```
redis-cli -h redis-example.fly.dev \
          -p 10000 \
          --cert redis-client.crt \
          --key redis-client.key \
          --tls \
          --cacert certs/rootCA.pem \
          --askpass
```

## Discuss

* You can discuss this example on the [community.fly.io](https://community.fly.io/t/new-redis-example/366) topic.

