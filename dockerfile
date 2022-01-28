FROM centos:8
ENV container docker

# Change password root
RUN echo "root:docker"|chpasswd

# Update image
RUN yum -y update && yum clean all

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

# Install openssh-server
RUN yum -y install openssh-server
RUN systemctl enable sshd
EXPOSE 22

# Install Java
ADD https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz .
RUN [ "tar", "xvf", "openjdk-17_linux-x64_bin.tar.gz" ]
RUN [ "mv", "jdk-17", "/opt/" ]
RUN [ "rm", "openjdk-17_linux-x64_bin.tar.gz" ]

ENV JAVA_HOME "/opt/jdk-17"
ENV PATH "$PATH:$JAVA_HOME/bin"

# Install mcrcon
WORKDIR /tools
RUN yum -y install gcc git
RUN git clone https://github.com/Tiiffi/mcrcon.git

WORKDIR /tools/mcrcon
RUN gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c

ENV MCRCON_HOME "/tools/mcrcon"
ENV MCRCON_HOST "127.0.0.1"
ENV MCRCON_PORT "25575"
ENV MCRCON_PASS "password"
ENV PATH "$PATH:$MCRCON_HOME"

# Setup minecraft server
WORKDIR /server

ADD https://launcher.mojang.com/v1/objects/125e5adf40c659fd3bce3e66e67a16bb49ecc1b9/server.jar .
COPY eula.txt .
COPY server.properties .
COPY server.sh .

EXPOSE 25565

CMD [ "/sbin/init", "/server/server.sh" ]