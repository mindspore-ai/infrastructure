FROM ubuntu:xenial
MAINTAINER tommylike <tommylikehu@gmail.com>

# Set env
USER root
ENV USER root
ENV PATH /usr/local/bin:$PATH
ENV PYTHON_ROOT_PATH /usr/local/python/python375

# Set apt source
RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak \
    && sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list

# Install base tools
RUN apt update \
    && apt install -y vim \
    && apt install -y wget \
    && apt install -y xz-utils \
    && apt install -y net-tools \
    && apt install -y openssh-client \
    && apt install -y git \
    && apt install -y curl \
    && apt install -y subversion \
    && apt install -y ntpdate \
    && apt install -y unzip \
    && apt install -y tzdata \
    && apt install -y tcl \
    && apt install -y sudo \
    && apt install -y bzip2 \
    && apt install -y libsm6 \
    && apt install -y default-jre

# Install compile tools
RUN apt install -y gcc \
    && apt install -y g++ \
    && apt install -y gfortran \
    && apt install -y make \
    && apt install -y libgmp-dev \
    && apt install -y patch \
    && apt install -y autoconf \
    && apt install -y libtool \
    && apt install -y automake \
    && apt install -y flex

# Set bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Install gcc-7.3.0(root)
RUN cd /tmp \
    && rm -f gcc-7.3.0-ubuntu16.04-Linux-x86_64.run \
    && wget http://59.36.11.51/tools/build/gcc/gcc-7.3.0/bin/gcc-7.3.0-ubuntu16.04-Linux-x86_64/gcc-7.3.0-ubuntu16.04-Linux-x86_64.run \
    && mkdir -pv /usr/local/gcc \
    && bash gcc-7.3.0-ubuntu16.04-Linux-x86_64.run /usr/local/gcc \
    && rm -f /tmp/gcc-7.3.0-ubuntu16.04-Linux-x86_64.run

# Set gcc env
ENV PATH /usr/local/gcc/gcc730/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/gcc/gcc730/lib64:$LD_LIBRARY_PATH

# Install python(root)
RUN apt install -y libffi-dev libssl-dev zlib1g-dev libbz2-dev libncurses5-dev libgdbm-dev liblzma-dev libreadline-dev \
    && cd /tmp \
    && rm -f /tmp/Python-3.7.5.tar.xz \
#   && wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz 
    && wget http://59.36.11.51/tools/build/python/Python-3.7.5.tar.xz \
    && tar -xf Python-3.7.5.tar.xz \
    && cd /tmp/Python-3.7.5 \
    && ./configure --prefix=${PYTHON_ROOT_PATH} --enable-shared \
    && make -j8 \
    && make install -j8 \
    && ./configure --prefix=${PYTHON_ROOT_PATH} \
    && make -j8 \
    && make install -j8 \
    && cd ${PYTHON_ROOT_PATH}/bin \
    && rm -f python \
    && rm -f pip \
    && ln -s python3.7 python \
    && ln -s pip3.7 pip \
    && echo "export PATH=${PYTHON_ROOT_PATH}/bin:\$PATH" >> ~/.bashrc \
    && rm -rf /tmp/Python-3.7.5 \
    && rm -f /tmp/Python-3.7.5.tar.xz

# Set pip source(root)
RUN mkdir /root/.pip \
    && echo "[global]" > /root/.pip/pip.conf \
    && echo "index-url=https://repo.huaweicloud.com/repository/pypi/simple" >> /root/.pip/pip.conf \
    && echo "trusted-host=repo.huaweicloud.com" >> /root/.pip/pip.conf \
    && echo "timeout=120" >> /root/.pip/pip.conf

# Install pip package(root)
COPY requirements.txt /tmp/
RUN chmod 644 /tmp/requirements.txt \
    && export PATH=${PYTHON_ROOT_PATH}/bin:$PATH \
    && pip3 install -r /tmp/requirements.txt \
    && pip3 list

# Install cmake(root)
RUN cd /tmp \
    && rm -f /tmp/cmake-3.14.1.tar.gz \
#   && wget https://github.com/Kitware/CMake/releases/download/v3.14.1/cmake-3.14.1.tar.gz 
    && wget http://59.36.11.51/tools/build/cmake/cmake-3.14.1.tar.gz \
    && tar -zxf cmake-3.14.1.tar.gz \
    && cd cmake-3.14.1 \
    && ./bootstrap --prefix=/usr --parallel=8 \
    && make -j8 \
    && make install -j8 \
    && rm -rf /tmp/cmake-3.14.1 \
    && rm -f /tmp/cmake-3.14.1.tar.gz

# Install nodejs(root)
RUN cd /tmp \
    && rm -f node-v10.19.0-linux-x64.tar.gz \
    && wget https://mirrors.huaweicloud.com/nodejs/latest-v10.x/node-v10.19.0-linux-x64.tar.gz \
    && rm -rf node-v10.19.0-linux-x64 \
    && tar -zxf node-v10.19.0-linux-x64.tar.gz \
    && rm -rf /usr/local/nodejs \
    && mkdir -pv /usr/local/nodejs \
    && mv /tmp/node-v10.19.0-linux-x64 /usr/local/nodejs/ \
    && chmod 755 -R /usr/local/nodejs \
    && ln -sf /usr/local/nodejs/node-v10.19.0-linux-x64/bin/node /usr/bin/node \
    && ln -sf /usr/local/nodejs/node-v10.19.0-linux-x64/bin/npm /usr/bin/npm \
    && npm config rm proxy \
    && npm config rm http-proxy \
    && npm config rm https-proxy \
    && npm config set no-proxy .huawei.com \
    && npm config set registry https://mirrors.huaweicloud.com/repository/npm \
    && rm -f /tmp/node-v10.19.0-linux-x64.tar.gz

# Install ccache
RUN cd /tmp \
    && rm -f /tmp/ccache-3.7.7.tar.gz \
#   && wget https://github.com/ccache/ccache/releases/download/v3.7.7/ccache-3.7.7.tar.gz 
    && wget http://59.36.11.51/tools/build/ccache/ccache-3.7.7.tar.gz \
    && tar -zxf ccache-3.7.7.tar.gz \
    && cd ccache-3.7.7 \
    && ./configure --prefix=/usr/local/ccache \
    && make -j8 \
    && make install -j8 \
    && rm -f /usr/local/bin/gcc \
    && rm -f /usr/local/bin/g++ \
    && rm -f /usr/local/bin/cc \
    && rm -f /usr/local/bin/c++ \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/gcc \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/g++ \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/cc \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/c++ \
    && /usr/local/ccache/bin/ccache -C \
    && /usr/local/ccache/bin/ccache --max-size=8 \
    && /usr/local/ccache/bin/ccache -p \
    && rm -rf /tmp/ccache-3.7.7 \
    && rm -f /tmp/ccache-3.7.7.tar.gz

# Reinstall git
# Problem: error: RPC failed; curl 56 GnuTLS recv error (-110): The TLS connection was non-properly terminated
RUN cd /tmp \
    && rm -f git-huawei_2.18.0.25_amd64.deb \
    && wget http://59.36.11.51/tools/build/git/git-huawei/git-huawei_2.18.0.25_amd64.deb \
    && dpkg -i git-huawei_2.18.0.25_amd64.deb \
    && rm -f git-huawei_2.18.0.25_amd64.deb

# Setup java path
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH $PATH:$JAVA_HOME/bin

# Create user of jenkins
ARG VERSION=3.35
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}

# Set sudo
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install gcc-7.3.0(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
    && ${MINDSPORE_CMD} "cd /tmp; rm -f gcc-7.3.0-ubuntu16.04-Linux-x86_64.run; wget http://59.36.11.51/tools/build/gcc/gcc-7.3.0/bin/gcc-7.3.0-ubuntu16.04-Linux-x86_64/gcc-7.3.0-ubuntu16.04-Linux-x86_64.run" \
    && ${MINDSPORE_CMD} "cd /tmp; mkdir -pv /home/jenkins/tools/gcc; bash gcc-7.3.0-ubuntu16.04-Linux-x86_64.run /home/jenkins/tools/gcc" \
    && ${MINDSPORE_CMD} "rm -f /tmp/gcc-7.3.0-ubuntu16.04-Linux-x86_64.run"

# Install python(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
#   && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/Python-3.7.5.tar.xz; wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz; tar -xf Python-3.7.5.tar.xz" 
    && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/Python-3.7.5.tar.xz; wget http://59.36.11.51/tools/build/python/Python-3.7.5.tar.xz; tar -xf Python-3.7.5.tar.xz" \
    && ${MINDSPORE_CMD} "export PATH=/home/jenkins/tools/gcc/gcc730/bin:$PATH; export LD_LIBRARY_PATH=/home/jenkins/tools/gcc/gcc730/lib64:$LD_LIBRARY_PATH; cd /tmp/Python-3.7.5; ./configure --prefix=/home/jenkins/tools/python375 --enable-shared && make -j8 && make install -j8" \
    && ${MINDSPORE_CMD} "export PATH=/home/jenkins/tools/gcc/gcc730/bin:$PATH; export LD_LIBRARY_PATH=/home/jenkins/tools/gcc/gcc730/lib64:$LD_LIBRARY_PATH; cd /tmp/Python-3.7.5; ./configure --prefix=/home/jenkins/tools/python375 && make -j8 && make install -j8" \
    && ${MINDSPORE_CMD} "cd /home/jenkins/tools/python375/bin; rm -f python; rm -f pip; ln -s python3.7 python; ln -s pip3.7 pip" \
    && ${MINDSPORE_CMD} "echo 'export PATH=/home/jenkins/tools/python375/bin:\$PATH' >> ~/.bashrc" \
    && ${MINDSPORE_CMD} "rm -rf /tmp/Python-3.7.5; rm -f /tmp/Python-3.7.5.tar.xz"

# Set pip source(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
    && ${MINDSPORE_CMD} "mkdir -pv /home/jenkins/.pip; echo '[global]' > /home/jenkins/.pip/pip.conf" \
    && ${MINDSPORE_CMD} "echo 'index-url=https://repo.huaweicloud.com/repository/pypi/simple' >> /home/jenkins/.pip/pip.conf" \
    && ${MINDSPORE_CMD} "echo 'trusted-host=repo.huaweicloud.com' >> /home/jenkins/.pip/pip.conf" \
    && ${MINDSPORE_CMD} "echo 'timeout=120' >> /home/jenkins/.pip/pip.conf"

# Install pip package(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
    && ${MINDSPORE_CMD} "export PATH=/home/jenkins/tools/python375/bin:$PATH; pip3 install -r /tmp/requirements.txt; pip3 list"

# Install cmake(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
#   && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/cmake-3.14.1.tar.gz; wget https://github.com/Kitware/CMake/releases/download/v3.14.1/cmake-3.14.1.tar.gz; tar -zxf cmake-3.14.1.tar.gz" 
    && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/cmake-3.14.1.tar.gz; wget http://59.36.11.51/tools/build/cmake/cmake-3.14.1.tar.gz; tar -zxf cmake-3.14.1.tar.gz" \
    && ${MINDSPORE_CMD} "export PATH=/home/jenkins/tools/gcc/gcc730/bin:$PATH; export LD_LIBRARY_PATH=/home/jenkins/tools/gcc/gcc730/lib64:$LD_LIBRARY_PATH; cd /tmp/cmake-3.14.1; ./bootstrap --prefix=/home/jenkins/tools/cmake --parallel=8; make -j8; make install -j8" \
    && ${MINDSPORE_CMD} "echo 'export PATH=/home/jenkins/tools/cmake/bin:\$PATH' >> ~/.bashrc" \
    && ${MINDSPORE_CMD} "rm -rf /tmp/cmake-3.14.1; rm -f /tmp/cmake-3.14.1.tar.gz"

# Set sshd and timezone
RUN sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config \
    && rm -f /etc/localtime \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && echo "export TZ='Asia/Shanghai'" >> /etc/profile \
    && export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
    && ${MINDSPORE_CMD} "echo export TZ='Asia/Shanghai' >> ~/.bashrc"

# Install jenkins slave
RUN mkdir -p /usr/share/jenkins/ \
  && cd /usr/share/jenkins/ \
  && wget -O agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

# Install jnlp
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod 755 /usr/local/bin/jenkins-agent \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

# Setting up env
USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

ENTRYPOINT ["jenkins-agent"]
