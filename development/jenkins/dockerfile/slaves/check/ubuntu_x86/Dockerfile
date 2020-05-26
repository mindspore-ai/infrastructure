# ubuntu:xenial-20200326
# DIGEST:sha256:a4fc0c40360ff2224db3a483e5d80e9164fe3fdce2a8439d2686270643974632
FROM ubuntu:xenial
MAINTAINER tommylike <tommylikehu@gmail.com>

##############
# User: root #
##############
# Set env
USER root
ENV USER root
ENV PATH /usr/local/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/default-java
ENV PATH $PATH:$JAVA_HOME/bin
ARG PYTHON_PATH=/usr/local/python/python375
ENV PATH ${PYTHON_PATH}/bin:$PATH
ARG VERSION=3.35
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent

# Set bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Set apt source
RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak \
    && sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
    && apt update

# Install base tools
RUN DEBIAN_FRONTEND=noninteractive apt install -y vim \
    wget \
    xz-utils \
    net-tools \
    openssh-client \
    git \
    curl \
    subversion \
    ntpdate \
    unzip \
    tzdata \
    tcl \
    sudo \
    bzip2 \
    default-jre

# Install compile tools
RUN DEBIAN_FRONTEND=noninteractive apt install -y gcc \
    g++ \
    gfortran \
    make
    
# Install dependency lib of python
RUN DEBIAN_FRONTEND=noninteractive apt install -y libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libncurses5-dev \
    libgdbm-dev \
    liblzma-dev \
    libreadline-dev
    
# Install dependency lib of cppcheck
RUN DEBIAN_FRONTEND=noninteractive apt install -y libpcre3-dev

# Install python
RUN cd /tmp \
    && wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz \
    && tar -xf Python-3.7.5.tar.xz \
    && cd /tmp/Python-3.7.5 \
    && ./configure --prefix=${PYTHON_PATH} \
    && make -j8 \
    && make install -j8 \
    && cd ${PYTHON_PATH}/bin \
    && rm -f python \
    && rm -f pip \
    && ln -s python3.7 python \
    && ln -s pip3.7 pip \
    && rm -rf /tmp/Python-3.7.5 \
    && rm -f /tmp/Python-3.7.5.tar.xz

# Set pip source
RUN mkdir /root/.pip \
    && echo "[global]" > /root/.pip/pip.conf \
    && echo "index-url=https://repo.huaweicloud.com/repository/pypi/simple" >> /root/.pip/pip.conf \
    && echo "trusted-host=repo.huaweicloud.com" >> /root/.pip/pip.conf \
    && echo "timeout=120" >> /root/.pip/pip.conf

# Install cpplint
RUN pip3 install cpplint==1.4.5

# Install pylint
RUN pip3 install pylint==2.3.1

# Install cppcheck
RUN cd /tmp \
    && wget https://github.com/danmar/cppcheck/archive/1.90.tar.gz \
    && tar -zxf 1.90.tar.gz \
    && cd cppcheck-1.90 \
    && make MATCHCOMPILER=yes FILESDIR=/usr/share/cppcheck HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" -j8 \
    && make install FILESDIR=/usr/share/cppcheck -j8 \
    && rm -rf /tmp/cppcheck-1.90 \
    && rm -f /tmp/1.90.tar.gz

# Install shellcheck
RUN cd /tmp \
    && wget https://github.com/koalaman/shellcheck/releases/download/v0.7.1/shellcheck-v0.7.1.linux.x86_64.tar.xz \
    && tar -xf shellcheck-v0.7.1.linux.x86_64.tar.xz \
    && rm -f /usr/bin/shellcheck \
    && mv /tmp/shellcheck-v0.7.1/shellcheck /usr/bin/shellcheck \
    && chmod 755 /usr/bin/shellcheck \
    && rm -rf /tmp/shellcheck-v0.7.1 \
    && rm -f /tmp/shellcheck-v0.7.1.linux.x86_64.tar.xz

# Install clang-format
RUN cd /tmp \
    && wget https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz \
    && tar xf clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz \
    && rm -rf /usr/local/clang-format \
    && mkdir -p /usr/local/clang-format/bin \
    && mkdir -p /usr/local/clang-format/lib \
    && mv /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04/bin/clang-format /usr/local/clang-format/bin/ \
    && mv /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04/lib/libc++abi.so* /usr/local/clang-format/lib/ \
    && mv /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04/lib/libc++.so* /usr/local/clang-format/lib/ \
    && chmod 755 -R /usr/local/clang-format \
    && rm -rf /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04 \
    && rm -f /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz

# Reinstall git
# Fix problem: error: RPC failed; curl 56 GnuTLS recv error (-110): The TLS connection was non-properly terminated
RUN cd /tmp \
    && wget https://tools.mindspore.cn/tools/ci/git/git-huawei/git-huawei_2.18.0.25_amd64.deb \
    && dpkg -i git-huawei_2.18.0.25_amd64.deb \
    && rm -f /tmp/git-huawei_2.18.0.25_amd64.deb

# Set timezone
RUN rm -f /etc/localtime \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && echo "export TZ='Asia/Shanghai'" >> /etc/profile

# Install jenkins slave
RUN mkdir -p /usr/share/jenkins/ \
    && wget https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar -O /usr/share/jenkins/agent.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/agent.jar \
    && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

# Install jnlp
RUN cd /tmp \
    && git clone https://github.com/jenkinsci/docker-inbound-agent.git -b 3.35-5 \
    && cp -a /tmp/docker-inbound-agent/jenkins-agent /usr/local/bin/jenkins-agent \
    && chmod 755 /usr/local/bin/jenkins-agent \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave \
    && rm -rf /tmp/docker-inbound-agent

# Create user of jenkins
RUN groupadd -g ${gid} ${group} \
    && useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user} \
    && echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#################
# User: jenkins #
#################
# Set env
USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN echo "export TZ='Asia/Shanghai'" >> ~/.bashrc \
    && mkdir -p /home/${user}/.jenkins \
    && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}
ENTRYPOINT ["jenkins-agent"]
