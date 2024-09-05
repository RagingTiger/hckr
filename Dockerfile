# Production image
FROM ubuntu:20.04

# Set environment variables to non-interactive mode to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    ffmpeg \
    gcc \
    git \
    jq \
    python3 \
    python3-pip \
    rsync \
    make \
    openssh-client \
    parallel \
    webp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi

# Install python packages
RUN pip3 install --no-cache-dir --upgrade \
    bs4 \
    gallery-dl \
    yt-dlp

# Install slack CLI
ARG SLKVERS=0.18.0
RUN cd /tmp && \
    curl -fsSL -o slack.tar.gz https://github.com/rockymadden/slack-cli/archive/v${SLKVERS}.tar.gz && \
    tar -xvzf slack.tar.gz && \
    cd slack-cli-${SLKVERS} && \
    make install bindir='/usr/local/bin' etcdir='/usr/etc' && \
    rm -rf /tmp/*

# Setup rc file
COPY root/ /root/

# Link ytb2slk executable
RUN chmod +x /root/*.sh && \
    ln /root/scrp2slk.sh /usr/bin/scrp2slk && \
    ln /root/ytb2slk.sh /usr/bin/ytb2slk && \
    ln /root/insta2slk.sh /usr/bin/insta2slk && \
    ln /root/slkup.sh /usr/bin/slkup && \
    ln /root/monitdir.sh /usr/bin/monitdir

# Create work directory
WORKDIR /home/hckr

CMD ["/bin/bash"]
