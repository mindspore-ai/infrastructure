FROM centos:centos7
MAINTAINER tommylike <tommylikehu@gmail.com>

USER root

# Install createrepo
RUN yum -y install createrepo && \
    yum -y install epel-release && \
    yum -y install curl && \
    yum -y install wget && \
    yum -y install ssh && \
    yum -y install rsync && \
    yum -y install python36 && \
    pip3 install pytz

COPY entrypoint.sh /usr/local/bin/
COPY repo_tools.py /root/


ENTRYPOINT ["entrypoint.sh"]
