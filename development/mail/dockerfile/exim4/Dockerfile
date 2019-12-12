FROM ubuntu:14.04

LABEL version="1.0.0"
LABEL maintainer="developer@openeuler.org"

ENV TINI_VERSION v0.14.0
RUN set -x \
  && apt-get update \
  && apt-get install -y ca-certificates curl --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" -o /usr/local/bin/tini \
  && curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc" -o /usr/local/bin/tini.asc \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
  && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
  && rm -r "$GNUPGHOME" /usr/local/bin/tini.asc \
  && chmod +x /usr/local/bin/tini \
  && tini -h \
  && apt-get purge --auto-remove -y ca-certificates curl

RUN apt-get update && apt-get install -y exim4 && rm -rf /var/lib/apt/lists/*

EXPOSE 25
CMD ["tini", "--", "exim", "-bd", "-v"]