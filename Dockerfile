# Base image
FROM ubuntu

# install goodies
RUN apt-get update && apt-get install -y \
	cowsay \
	gcc \
	git \
	make \
	nmap \
	netcat \
	tcpdump

## get github repos and build
# hashcat
WORKDIR /usr/src
RUN git clone https://github.com/hashcat/hashcat.git
WORKDIR /usr/src/hashcat
RUN git submodule update --init && \
	make && \
	make install

# create work dir
RUN mkdir -p /home/hckr

# set work dir
WORKDIR /home/hckr
		
