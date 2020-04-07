FROM ubuntu:xenial
MAINTAINER tommylike <tommylikehu@gmail.com>
# Set env
USER root
ENV USER root

RUN apt -y update \
    && apt install -y wget \
    && apt install -y git \
    && apt install -y make build-essential libpcre3 libpcre3-dev openssl libssl-dev software-properties-common tzdata\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# install mmdb
RUN add-apt-repository -y ppa:maxmind/ppa \
    && apt -y update && apt -y install libmaxminddb0 libmaxminddb-dev mmdb-bin \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# prepare nginx
RUN wget http://nginx.org/download/nginx-1.10.3.tar.gz \
    && tar -xvf nginx-1.10.3.tar.gz && rm nginx-1.10.3.tar.gz

# prepare nginx fancyindex
RUN git clone https://github.com/aperezdc/ngx-fancyindex.git ngx-fancyindex

# prepare geoip_module
RUN wget https://github.com/leev/ngx_http_geoip2_module/archive/master.tar.gz && \
    tar -xvf master.tar.gz && \
    mv ngx_http_geoip2_module-master ngx_http_geoip2_module && \
    rm master.tar.gz

RUN cd nginx-1.10.3 \
    && ./configure --prefix=/etc/nginx/ --add-module=../ngx-fancyindex --with-http_ssl_module --with-http_realip_module --add-module=../ngx_http_geoip2_module\
    && make && make install \
    && cd ../ && rm -rf nginx-1.10.3  && rm -rf ngx-fancyindex && rm -rf ngx_http_geoip2_module\
    && mkdir -p /var/log/nginx

# prepare geo database
RUN mkdir /etc/nginx/geoip && cd /etc/nginx/geoip && \
    wget https://mindspore.obs.cn-north-4.myhuaweicloud.com:443/GeoLite2-Country_20200331.tar.gz && \
    tar -xvf GeoLite2-Country_20200331.tar.gz && mv GeoLite2-Country_20200331 country && rm GeoLite2-Country_20200331.tar.gz &&\
    wget https://mindspore.obs.cn-north-4.myhuaweicloud.com:443/GeoLite2-City_20200331.tar.gz && \
    tar -xvf GeoLite2-City_20200331.tar.gz && mv GeoLite2-City_20200331 city && rm GeoLite2-City_20200331.tar.gz

ENV PATH="/etc/nginx/sbin:${PATH}"
ENV GEO_COUNTRY_DB_PATH="/etc/nginx/geoip/country/GeoLite2-Country.mmdb"
ENV GEO_CITY_DB_PATH="/etc/nginx/geoip/city/GeoLite2-City.mmdb"
ENTRYPOINT ["nginx", "-g", "daemon off;"]