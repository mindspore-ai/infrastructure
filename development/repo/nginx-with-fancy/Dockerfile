FROM ubuntu:xenial
MAINTAINER tommylike <tommylikehu@gmail.com>
# Set env
USER root
ENV USER root

RUN apt -y update \
    && apt install -y wget \
    && apt install -y git \
    && apt install -y make build-essential libpcre3 libpcre3-dev openssl libssl-dev \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN wget http://nginx.org/download/nginx-1.10.3.tar.gz \
    && tar -xvf nginx-1.10.3.tar.gz

RUN git clone https://github.com/aperezdc/ngx-fancyindex.git ngx-fancyindex

RUN cd nginx-1.10.3 \
    && ./configure --prefix=/etc/nginx/ --add-module=../ngx-fancyindex --with-http_ssl_module \
    && make && make install \
    && cd ../ && rm -rf nginx-1.10.3 && rm nginx-1.10.3.tar.gz && rm -rf ngx-fancyindex \
    && mkdir -p /var/log/nginx


ENV PATH="/etc/nginx/sbin:${PATH}"
ENTRYPOINT ["nginx", "-g", "daemon off;"]