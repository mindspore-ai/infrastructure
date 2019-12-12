FROM frolvlad/alpine-python3:latest

MAINTAINER TommyLike <tommylikehu@gmail.com>

COPY mailman-core-utils.py /opt/mailman-utils/mailman-core-utils.py

COPY docker-entrypoint.sh /usr/local/bin/

RUN apk add curl && \
    pip3 install requests && \
    pip3 install mailmanclient==3.3.0 && \
    rm -r /root/.cache

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR /opt/mailman-utils

CMD ["python3", "-u", "mailman-core-utils.py"]
