# Base image
FROM kalilinux/kali-linux-docker

# install goodies
RUN apt-get update && apt-get install -y \
	aircrack-ng \
	curl \
	cowsay \
	gcc \
	git \
	make \
	nmap \
	netcat \
	pciutils \
	pv \
        python-pip \
	tcpdump \
	youtube-dl \
	wget

# update all python packages
RUN pip install -U youtube-dl

# setup rc file
COPY .bashrc /root/

# create work dir
RUN mkdir -p /home/hckr
WORKDIR /home/hckr

## now clean up
RUN rm -rf /tmp/*
