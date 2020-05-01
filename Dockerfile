# Production image
FROM alpine:3.10

# install goodies
RUN apk add --no-cache \
        bash \
        bash-doc \
        bash-completion \
        curl \
        ffmpeg \
        git \
        jq \
        make \
        openssh \
        python3=3.7.5-r1 \
        rsync && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache  --upgrade youtube-dl gallery-dl

# install slack
ARG SLKVERS=0.18.0
RUN cd /tmp && \
    curl -fsSL -o slack.tar.gz https://github.com/rockymadden/slack-cli/archive/v${SLKVERS}.tar.gz && \
    tar -xvzf slack.tar.gz && \
    cd slack-cli-${SLKVERS} && \
    make install bindir='/usr/local/bin' etcdir='/usr/etc' && \
    rm -rf /tmp/*     

# setup rc file
COPY root/ /root/

# link ytb2slk executable
RUN chmod +x /root/*.sh && \
    ln /root/ytb2slk.sh /usr/bin/ytb2slk && \
    ln /root/insta2slk.sh /usr/bin/insta2slk

# create work dir
WORKDIR /home/hckr

CMD ["/bin/bash"]
