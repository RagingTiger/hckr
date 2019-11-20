# Builder image
FROM golang:alpine3.10 AS builder

# set vegeta build args
ARG VEGETA_SRC=github.com/tsenart/vegeta
ARG VEGETA_VERS=v12.7.0

# build vegeta
RUN apk --no-cache add build-base git bzr mercurial gcc && \
    go get -u -d ${VEGETA_SRC} && \
    cd /go/src/${VEGETA_SRC} && \
    git checkout -b ${VEGETA_VERS} && \
    echo "building vegeta version: ${VEGETA_VERS}" && \
    go install ${VEGETA_SRC}

# Production image
FROM alpine:3.10

# copy from builder
COPY --from=builder /go/bin/vegeta /usr/bin/vegeta

# install goodies
RUN apk add --no-cache bash bash-doc bash-completion ffmpeg python3=3.7.5-r1 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache  --upgrade youtube-dl 

# setup rc file
COPY root/ /root/

# create work dir
WORKDIR /home/hckr

CMD ["/bin/bash"]
