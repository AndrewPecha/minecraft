To run use the below as an example
```
docker run -d -u root --name=minecraft -h minecraft -p 25565:25565 -p 22:22 -v server:/opt/minecraft/server --tmpfs /run --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro minecraft
```