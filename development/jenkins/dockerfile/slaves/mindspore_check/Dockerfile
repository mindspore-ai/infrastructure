FROM ubuntu:xenial
MAINTAINER tommylike <tommylikehu@gmail.com>

# Install jdk8 and bunch of build tools
USER root
ENV USER root


ENV PATH /usr/local/bin:$PATH

# Install base tools
RUN apt update \
    && apt install -y wget \
    && apt install -y curl \
    && apt install -y git \
    && apt install -y subversion \
    && apt install -y default-jre \
    && apt install -y vim \
    && apt install -y xz-utils \
    && apt install -y net-tools \
    && apt install -y openssh-client

# Install compile tools
RUN apt install -y gcc g++ make

# Install python
RUN apt install -y libffi-dev libssl-dev zlib1g-dev libbz2-dev libncurses5-dev libgdbm-dev liblzma-dev libreadline-dev \
    && cd /tmp \
    && rm -f /tmp/Python-3.7.3.tar.xz \
    && wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz \
    && tar -xf Python-3.7.3.tar.xz \
    && cd /tmp/Python-3.7.3 \
    && ./configure \
    && make -j4 \
    && make install -j4 \
    && rm -f /usr/local/bin/python \
    && ln -s /usr/local/bin/python3.7 /usr/local/bin/python \
    && rm -rf /tmp/Python-3.7.3 \
    && rm -f /tmp/Python-3.7.3.tar.xz

# Set pip source
RUN mkdir /root/.pip \
    && echo "[global]" > /root/.pip/pip.conf \
    && echo "trusted-host=mirrors.aliyun.com" >> /root/.pip/pip.conf \
    && echo "index-url=http://mirrors.aliyun.com/pypi/simple/" >> /root/.pip/pip.conf

# Install cpplint
RUN pip3 install cpplint==1.4.4

# Install pylint
RUN pip3 install pylint==2.3.1 \
    && rm -f /usr/local/etc/pylintrc \
    && wget -O /usr/local/etc/pylintrc https://raw.githubusercontent.com/tensorflow/tensorflow/master/tensorflow/tools/ci_build/pylintrc

# Install cppcheck
RUN apt install -y libpcre3-dev \
    && cd /tmp \
    && rm -f /tmp/1.89.tar.gz \
    && wget https://github.com/danmar/cppcheck/archive/1.89.tar.gz \
    && tar -zxf 1.89.tar.gz \
    && cd cppcheck-1.89 \
    && make MATCHCOMPILER=yes FILESDIR=/usr/share/cppcheck HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" -j4 \
    && make install FILESDIR=/usr/share/cppcheck -j4 \
    && rm -rf /tmp/cppcheck-1.89 \
    && rm -f /tmp/1.89.tar.gz

# Install shellcheck
RUN cd /tmp \
    && rm -f /tmp/shellcheck-stable.linux.x86_64.tar.xz \
    && wget https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz \
    && tar -xf shellcheck-stable.linux.x86_64.tar.xz \
    && rm -f /usr/bin/shellcheck \
    && mv /tmp/shellcheck-stable/shellcheck /usr/bin/shellcheck \
    && chmod 755 /usr/bin/shellcheck \
    && rm -rf /tmp/shellcheck-stable \
    && rm -f /tmp/shellcheck-stable.linux.x86_64.tar.xz

# Install cloc
RUN cd /tmp \
    && rm -f /tmp/cloc-1.84.tar.gz \
    && wget https://github.com/AlDanial/cloc/releases/download/1.84/cloc-1.84.tar.gz \
    && tar -zxf cloc-1.84.tar.gz \
    && rm -rf /usr/local/cloc \
    && mv /tmp/cloc-1.84 /usr/local/cloc \
    && rm -f /tmp/cloc-1.84.tar.gz

# Setup java path
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH $PATH:$JAVA_HOME/bin

# Install jenkins slave
ARG VERSION=3.35
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}

ARG AGENT_WORKDIR=/home/${user}/agent

RUN mkdir -p /usr/share/jenkins/ \
  && cd /usr/share/jenkins/ \
  && wget -O agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar


# Install jnlp
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave


# Setting up env
USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

ENTRYPOINT ["jenkins-agent"]
