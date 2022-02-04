To run use the below as an example
```
docker run -d -p 25565:25565 -p 22:22 -v server:/opt/minecraft/server --tmpfs /run --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro shamonj03/minecraft
```

# Elevating User Privileges
This image also comes pre-loaded with [mcrcon](https://github.com/tiiffi/mcrcon). Users can be elevated using the following:

```
docker exec -it <image name here> /bin/bash
```

You should now be in a bash shell inside the container. You can run the following to grant the elevated privileges:

```shell
mcrcon
op <player name here>
```