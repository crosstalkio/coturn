FROM alpine:3.11 as builder

# Build and install Coturn
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        ca-certificates \
        curl \
    && update-ca-certificates \
    \
 # Install tools for building
    && apk add --no-cache --virtual .tool-deps \
        coreutils autoconf g++ libtool make \
    \
 # Install build dependencies
    && apk add --no-cache --virtual .build-deps \
        linux-headers \
        libevent-dev \
        openssl-dev \
        hiredis-dev \
    \
 # Download and prepare sources
    && curl -fL -o /tmp/coturn.tar.gz \
         https://github.com/coturn/coturn/archive/4.5.1.1.tar.gz \
    && tar -xzf /tmp/coturn.tar.gz -C /tmp/ \
    && cd /tmp/coturn-* \
    \
 # Build from sources
    && ./configure --prefix=/usr \
        --turndbdir=/var/lib/coturn \
        --disable-rpath \
        --sysconfdir=/etc/coturn \
        # No documentation included to keep image size smaller
        --mandir=/tmp/coturn/man \
        --docsdir=/tmp/coturn/docs \
        --examplesdir=/tmp/coturn/examples \
    && make \
    \
 # Install and configure
    && make install \
 # Preserve license file
    && mkdir -p /usr/share/licenses/coturn/ \
    && cp /tmp/coturn/docs/LICENSE /usr/share/licenses/coturn/ \
 # Remove default config file
    && rm -f /etc/coturn/turnserver.conf.default \
    \
 # Cleanup unnecessary stuff
    && apk del .tool-deps .build-deps \
    && rm -rf /var/cache/apk/* \
           /tmp/*

FROM alpine:3.11

 # Install runtime dependencies
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
    libevent \
    libcrypto1.1 libssl1.1 \
    hiredis \
    && rm -rf /var/cache/apk/* /tmp/*

COPY --from=builder /usr/bin/turnserver /usr/bin/

EXPOSE 3478 3479 3478/udp 3479/udp
EXPOSE 49152-65535/udp

VOLUME ["/var/lib/redis"]

CMD ["/usr/bin/turnserver", "-n", "--log-file=stdout"]
