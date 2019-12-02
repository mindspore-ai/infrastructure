FROM anapsix/alpine-java:8u202b08_jdk

MAINTAINER tommylikehu@gmail.com

USER root

RUN apk update && \
    apk add curl && \
    apk add jq && \
    apk add xmlstarlet

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]
