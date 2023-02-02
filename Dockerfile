FROM ubuntu:22.04

LABEL version="1.0"
LABEL description="Autopsy in a Docker environment"
LABEL maintainer="Corey Forman - https://github.com/digitalsleuth/autopsy-docker"
ARG AUTOPSY_VERSION=4.20.0
ARG SLEUTHKIT_VERSION=4.12.0

ENV TERM linux

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && apt-get install sudo git nano curl wget gnupg unzip ssh -y
WORKDIR /tmp
RUN wget https://github.com/sleuthkit/autopsy/releases/download/autopsy-${AUTOPSY_VERSION}/autopsy-${AUTOPSY_VERSION}.zip && \
    wget https://github.com/sleuthkit/autopsy/raw/develop/linux_macos_install_scripts/install_application.sh && \
    wget https://github.com/sleuthkit/autopsy/raw/develop/linux_macos_install_scripts/install_prereqs_ubuntu.sh && \
    wget https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-${SLEUTHKIT_VERSION}/sleuthkit-java_${SLEUTHKIT_VERSION}-1_amd64.deb && \
    bash /tmp/install_prereqs_ubuntu.sh && \
    apt-get install /tmp/sleuthkit-java_${SLEUTHKIT_VERSION}-1_amd64.deb -y && \
    bash /tmp/install_application.sh -z /tmp/autopsy-${AUTOPSY_VERSION}.zip -i /usr/local/share -j /usr/lib/jvm/bellsoft-java8-full-amd64 && \
    ln -s /usr/local/share/autopsy-${AUTOPSY_VERSION}/bin/autopsy /usr/local/bin/autopsy && \
    chmod 755 /usr/local/share/autopsy-${AUTOPSY_VERSION}/bin/autopsy && \
    rm /tmp/sleuthkit-java_${SLEUTHKIT_VERSION}-1_amd64.deb /tmp/autopsy-${AUTOPSY_VERSION}.zip

RUN sed -Ei 's/^#UseDNS no/UseDNS no/' /etc/ssh/sshd_config && \
sed -Ei 's/^#GSSAPIAuthentication no/GSSAPIAuthentication no/' /etc/ssh/sshd_config && \
sed -Ei 's/^#PrintLastLog yes/PrintLastLog yes/' /etc/ssh/sshd_config && \
sed -Ei 's/^#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config && \
sed -Ei 's/^#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config && \
sed -Ei 's/^#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config

RUN groupadd -r -g 1000 autopsy && \
useradd -r -g autopsy -d /home/autopsy -s /bin/bash -c "Autopsy User" -u 1000 autopsy && \
mkdir /home/autopsy && \
touch /home/autopsy/.Xauthority && \
chown -R autopsy:autopsy /home/autopsy && \
usermod -a -G sudo autopsy && \
echo 'autopsy:forensics' | chpasswd 

RUN apt-get autoremove --purge -y && \
    apt-get clean -y

WORKDIR /home/autopsy

RUN mkdir /var/run/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
