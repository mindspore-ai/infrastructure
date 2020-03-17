FROM ubuntu:xenial
MAINTAINER tommylike <tommylikehu@gmail.com>

# Set env
USER root
ENV USER root
ENV TZ Asia/Shanghai
ENV PATH /usr/local/bin:$PATH
ENV PYTHON_ROOT_PATH /usr/local/python/python375

# Set apt source
RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak \
    && sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list

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
    && apt install -y openssh-client \
    && apt install -y tzdata

# Install compile tools
RUN apt install -y gcc \
    && apt install -y g++ \
    && apt install -y make

# Set bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Install python(root)
RUN apt install -y libffi-dev libssl-dev zlib1g-dev libbz2-dev libncurses5-dev libgdbm-dev liblzma-dev libreadline-dev \
    && cd /tmp \
    && rm -f /tmp/Python-3.7.5.tar.xz \
#   && wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz 
    && wget http://59.36.11.51/tools/build/python/Python-3.7.5.tar.xz \
    && tar -xf Python-3.7.5.tar.xz \
    && cd /tmp/Python-3.7.5 \
    && ./configure --prefix=${PYTHON_ROOT_PATH} --enable-shared \
    && make -j4 \
    && make install -j4 \
    && ./configure --prefix=${PYTHON_ROOT_PATH} \
    && make -j4 \
    && make install -j4 \
    && rm -f /usr/local/bin/python3 \
    && rm -f /usr/local/bin/python \
    && rm -f /usr/local/bin/pip3 \
    && rm -f /usr/local/bin/pip \
    && ln -s ${PYTHON_ROOT_PATH}/bin/python3.7 /usr/local/bin/python3 \
    && ln -s ${PYTHON_ROOT_PATH}/bin/python3.7 /usr/local/bin/python \
    && ln -s ${PYTHON_ROOT_PATH}/bin/pip3.7 /usr/local/bin/pip3 \
    && ln -s ${PYTHON_ROOT_PATH}/bin/pip3.7 /usr/local/bin/pip \
    && rm -rf /tmp/Python-3.7.5 \
    && rm -f /tmp/Python-3.7.5.tar.xz

# Set pip source(root)
RUN mkdir /root/.pip \
    && echo "[global]" > /root/.pip/pip.conf \
    && echo "index-url=https://repo.huaweicloud.com/repository/pypi/simple" >> /root/.pip/pip.conf \
    && echo "trusted-host=repo.huaweicloud.com" >> /root/.pip/pip.conf \
    && echo "timeout=120" >> /root/.pip/pip.conf

# Install cpplint
RUN export PATH=${PYTHON_ROOT_PATH}/bin:$PATH \
    && pip3 install cpplint==1.4.4

# Install pylint
RUN export PATH=${PYTHON_ROOT_PATH}/bin:$PATH \
    && pip3 install pylint==2.3.1 \
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
    && wget https://github.com/koalaman/shellcheck/releases/download/v0.7.0/shellcheck-v0.7.0.linux.x86_64.tar.xz \
    && tar -xf shellcheck-v0.7.0.linux.x86_64.tar.xz \
    && rm -f /usr/bin/shellcheck \
    && mv /tmp/shellcheck-v0.7.0/shellcheck /usr/bin/shellcheck \
    && chmod 755 /usr/bin/shellcheck \
    && rm -rf /tmp/shellcheck-v0.7.0 \
    && rm -f /tmp/shellcheck-v0.7.0.linux.x86_64.tar.xz

# Install cloc
RUN cd /tmp \
    && rm -f /tmp/cloc-1.84.tar.gz \
    && wget https://github.com/AlDanial/cloc/releases/download/1.84/cloc-1.84.tar.gz \
    && tar -zxf cloc-1.84.tar.gz \
    && rm -rf /usr/local/cloc \
    && mv /tmp/cloc-1.84 /usr/local/cloc \
    && rm -f /tmp/cloc-1.84.tar.gz
    
# Install clang-format
RUN cd /tmp \
    && rm -f clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz \
#   && wget https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz
    && wget http://59.36.11.51/tools/static_check/clang-format/clang-format-9.0.1/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz \
    && rm -rf clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04 \
    && tar xf clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz \
    && rm -rf /usr/local/clang-format \
    && mkdir -pv /usr/local/clang-format/bin \
    && mkdir -pv /usr/local/clang-format/lib \
    && mv /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04/bin/clang-format /usr/local/clang-format/bin/ \
    && mv /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04/lib/libc++abi.so* /usr/local/clang-format/lib/ \
    && mv /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04/lib/libc++.so* /usr/local/clang-format/lib/ \
    && chmod 755 -R /usr/local/clang-format \
    && echo "export PATH=/usr/local/clang-format/bin:\$PATH" >> ~/.bashrc \
    && rm -rf /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04 \
    && rm -f /tmp/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz

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
RUN chmod +x /usr/local/bin/jenkins-agent \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

# Setting up env
USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

ENTRYPOINT ["jenkins-agent"]
