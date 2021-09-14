# syntax=docker/dockerfile:1.2
#
# Building scriot: <https://github.com/moparisthebest/static-curl/blob/master/build.sh>
# Official curl dockerfile: <https://github.com/curl/curl-docker/blob/master/alpine/latest/Dockerfile>

FROM alpine:3.14 as builder

ARG CURL_VERSION="7.78.0"

# install system dependencies
RUN apk add \
    build-base \
    clang \
    openssl-dev \
    nghttp2-dev \
    nghttp2-static \
    openssl-libs-static \
    autoconf \
    automake \
    libtool

WORKDIR /tmp

# download curl sources
RUN set -x \
    && wget -O curl.tar.gz "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz" \
    && tar xzf curl.tar.gz

# change working directory to the directory with curl sources
WORKDIR "/tmp/curl-${CURL_VERSION}"

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
    && make -j$(nproc) V=1 curl_LDFLAGS=-all-static \
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
    && mv "/tmp/curl-${CURL_VERSION}/src/curl" ./bin/curl \
    && echo 'curl:x:10001:10001::/nonexistent:/sbin/nologin' > ./etc/passwd \
    && echo 'curl:x:10001:' > ./etc/group \
    && cp -R /etc/ssl/certs ./etc/ssl/certs

# just for a test
RUN /tmp/rootfs/bin/curl --fail -o /dev/null https://github.com/robots.txt

# use empty filesystem
FROM scratch

LABEL \
    # Docs: <https://github.com/opencontainers/image-spec/blob/master/annotations.md>
    org.opencontainers.image.title="curl" \
    org.opencontainers.image.description="curl (static binary file) in a scratch docker image" \
    org.opencontainers.image.url="https://github.com/tarampampam/curl-docker" \
    org.opencontainers.image.source="https://github.com/tarampampam/curl-docker" \
    org.opencontainers.image.vendor="tarampampam" \
    org.opencontainers.image.licenses="WTFPL"

# use an unprivileged user
USER curl:curl

# import from builder
COPY --from=builder /tmp/rootfs /

ENTRYPOINT ["/bin/curl"]
