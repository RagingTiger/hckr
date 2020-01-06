# Go Builder image
FROM golang:alpine3.10 AS gobuilder

# set vegeta build args
ARG VEGETA_SRC=github.com/tsenart/vegeta
ARG VEGETA_VERS=v12.7.0

# build vegeta
RUN echo "\n ====> Starting Go Builder <==== \n" && \
    apk --no-cache add build-base git bzr mercurial gcc && \
    go get -u -d ${VEGETA_SRC} && \
    cd /go/src/${VEGETA_SRC} && \
    git checkout -b ${VEGETA_VERS} && \
    echo "building vegeta version: ${VEGETA_VERS}" && \
    go install ${VEGETA_SRC}

# Python Builder image
FROM python:3.7 AS pybuilder

RUN echo "\n ====> Starting Python Builder <==== \n" && \
    cd /usr/local/share && \
    git clone https://github.com/threat9/routersploit.git && \
    cd routersploit && \
    pip3 install --no-cache --upgrade -r requirements.txt

# Production image
FROM alpine:3.10

# copy from builder
COPY --from=gobuilder /go/bin/vegeta /usr/bin/vegeta

ARG PYTHON_VERS=python3.7 
ARG PYPATH=/usr/local/lib/${PYTHON_VERS}/site-packages/
ARG SRC_PATH=/usr/local/share
COPY --from=pybuilder ${PYPATH} ${PYTPATH}
COPY --from=pybuilder ${SRC_PATH} ${SRC_PATH}

# install goodies
RUN apk add --no-cache \
        bash \
        bash-doc \
        bash-completion \
        curl \
        ffmpeg \
        gcc \
        git \
        jq \
        make \
        python3=3.7.5-r1 \
        rsync && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache  --upgrade youtube-dl

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
RUN chmod +x /root/ytb2slk.sh && \
    ln /root/ytb2slk.sh /usr/bin/ytb2slk

# create work dir
WORKDIR /home/hckr

CMD ["/bin/bash"]
