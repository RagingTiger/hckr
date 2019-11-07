# Base image
FROM alpine:3.10

# install goodies
RUN apk add --no-cache bash bash-doc bash-completion python3=3.7.5-r1 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache  --upgrade youtube-dl 

# setup rc file
COPY .bashrc /root/

# create work dir
WORKDIR /home/hckr

CMD ["/bin/bash"]
