# syntax=docker/dockerfile:1.2
#
# Building script: <https://github.com/moparisthebest/static-curl/blob/master/build.sh>
# Official curl dockerfile: <https://github.com/curl/curl-docker/blob/master/alpine/latest/Dockerfile>

# e.g.: `docker build --rm --build-arg "BASE_IMAGE=alpine:latest" -f ./Dockerfile .`
ARG BASE_IMAGE="scratch"

FROM alpine:3.17 as builder

# renovate: source=github-tags name=curl/curl versioning=regex:^(?:curl-)?(?<major>\d+)_(?<minor>\d+)_(?<patch>\d+)$ extractVersion=^(?:curl-)?(?<version>[\d_]+)$
ENV CURL_VERSION="8_0_1"

# install system dependencies
RUN apk add \
    build-base \
    clang \
    openssl-dev \
    nghttp2-dev \
    nghttp2-static \
    openssl-libs-static \
    zlib-static \
    autoconf \
    automake \
    libtool

WORKDIR /tmp

# download curl sources
RUN set -x \
    && CURL_VERSION=$(echo $CURL_VERSION | sed s/_/./g) \
    && wget -O curl.tar.gz "https://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz" \
    && tar xzf curl.tar.gz \
    && rm curl.tar.gz \
    && mv ./curl-* ./src

# change working directory to the directory with curl sources
WORKDIR /tmp/src

# apply patches to the source code
COPY ./patches ./patches
RUN for f in ./patches/*.patch; do patch -p1 < "$f"; done

ENV CC="clang" \
    LDFLAGS="-static" \
    PKG_CONFIG="pkg-config --static"

RUN autoreconf -fi

#RUN ./configure --help=short && exit 1 # show the help

RUN ./configure \
    --disable-shared \
    --enable-static \
    \
    --enable-dnsshuffle \
    --enable-werror \
    \
    --disable-cookies \
    --disable-crypto-auth \
    --disable-dict \
    --disable-file \
    --disable-ftp \
    --disable-gopher \
    --disable-imap \
    --disable-ldap \
    --disable-pop3 \
    --disable-proxy \
    --disable-rtmp \
    --disable-rtsp \
    --disable-scp \
    --disable-sftp \
    --disable-smtp \
    --disable-telnet \
    --disable-tftp \
    --disable-versioned-symbols \
    --disable-doh \
    --disable-netrc \
    --disable-mqtt \
    --disable-largefile \
    --without-gssapi \
    --without-libidn2 \
    --without-libpsl \
    --without-librtmp \
    --without-libssh2 \
    --without-nghttp2 \
    --without-ntlm-auth \
    --without-brotli \
    --without-zlib \
    --with-ssl

# compile the curl
RUN set -x \
    && make -j$(nproc) V=1 LDFLAGS="-static -all-static" \
    && strip ./src/curl

# exit with error code 1 if the executable is dynamic, not static
RUN ldd ./src/curl && exit 1 || true

# print out some info about binary file
RUN set -x \
    && ls -lh ./src/curl \
    && file ./src/curl \
    && ./src/curl --version

WORKDIR /tmp/rootfs

# prepare the rootfs for scratch
RUN set -x \
    && mkdir -p ./bin ./etc/ssl \
    && mv /tmp/src/src/curl ./bin/curl \
    && echo 'curl:x:10001:10001::/nonexistent:/sbin/nologin' > ./etc/passwd \
    && echo 'curl:x:10001:' > ./etc/group \
    && cp -R /etc/ssl/certs ./etc/ssl/certs

# just for a test
RUN /tmp/rootfs/bin/curl --fail -o /dev/null https://cloudflare.com/robots.txt

FROM ${BASE_IMAGE}

LABEL \
    # Docs: <https://github.com/opencontainers/image-spec/blob/master/annotations.md>
    org.opencontainers.image.title="curl" \
    org.opencontainers.image.description="curl (static binary file) in docker image" \
    org.opencontainers.image.url="https://github.com/tarampampam/curl-docker" \
    org.opencontainers.image.source="https://github.com/tarampampam/curl-docker" \
    org.opencontainers.image.vendor="tarampampam" \
    org.opencontainers.image.licenses="WTFPL"

# use an unprivileged user
USER curl:curl

# import from builder
COPY --from=builder /tmp/rootfs /

ENTRYPOINT ["/bin/curl"]
