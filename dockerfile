FROM openjdk:17 as JDK

FROM centos:8 as Builder
RUN yum -y install gcc git
WORKDIR /opt/minecraft/tools
RUN git clone https://github.com/Tiiffi/mcrcon.git

WORKDIR /opt/minecraft/tools/mcrcon
RUN gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c

FROM centos:8

# Change password root
RUN chpasswd root:docker

# Update and install packages
RUN yum -y update && yum -y install cronie openssh-server && yum clean all

# Setup systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]

# Make dirs
RUN mkdir -p /opt/minecraft/{tools/mcrcon,server,backups}

# Copy JDK
COPY --from=JDK /usr/java/openjdk-17 /opt/jdk-17
ENV JAVA_HOME="/opt/jdk-17"

# Install mcrcon
COPY --from=Builder /opt/minecraft/tools/mcrcon /opt/minecraft/tools/mcrcon
ENV MCRCON_HOME="/opt/minecraft/tools/mcrcon" \
    MCRCON_HOST="127.0.0.1" \
    MCRCON_PORT="25575" \
    MCRCON_PASS="password"

# Update path
ENV PATH="$PATH:$JAVA_HOME:$MCRCON_HOME"

# Install auto backup script
WORKDIR /etc/cron.d
COPY ./cron.d/* .
RUN chmod 0644 backup-crontab
RUN ln -s backup-crontab /opt/minecraft/server/backup-crontab
RUN crontab backup-crontab

# Install minecraft server
WORKDIR /opt/minecraft/server
ADD https://launcher.mojang.com/v1/objects/125e5adf40c659fd3bce3e66e67a16bb49ecc1b9/server.jar .
COPY ./server/* .

#  Start the minecraft services
RUN systemctl link /opt/minecraft/server/minecraft.service
RUN systemctl enable sshd; systemctl enable crond; systemctl enable minecraft

# Open ports
EXPOSE 22 25565

CMD [ "/sbin/init" ]