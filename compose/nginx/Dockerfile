FROM nginx:mainline-alpine

RUN apk --no-cache upgrade && \
    # Install curl without specifying the version
    apk add --no-cache curl

# Install necessary packages for building libcurl from source
RUN apk --no-cache add \
    build-base \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    openssl-dev \
    zlib-dev \
    nghttp2-dev \
    brotli-dev \
    c-ares-dev \
    libssh2-dev \
    linux-headers

# Download, compile, and install libcurl 8.21.0

RUN curl -LO https://curl.se/download/curl-8.21.0.tar.gz && \
    tar -xzf curl-8.21.0.tar.gz && \
    cd curl-8.21.0 && \
    ./configure --with-ssl && \
    make && \
    make install && \
    cd .. && \
    rm -rf curl-8.21.0 curl-8.21.0.tar.gz

# Add SSL certificates and .htpasswd file
ADD ./ssl /etc/nginx/ssl
ADD ./conf/.htpasswd /etc/nginx/.htpasswd
ADD ./conf/nginx.conf /etc/nginx/nginx.conf