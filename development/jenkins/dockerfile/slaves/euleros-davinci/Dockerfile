# Base image euleros_aarch64:2.8
FROM swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/euleros_aarch64/euleros_aarch64:2.8.530
MAINTAINER tommylike <tommylikehu@gmail.com>

# Set env
USER root
ENV USER root
ENV PATH /usr/local/bin:$PATH
ENV PYTHON_ROOT_PATH /usr/local/python/python375

# Set yum source
RUN repo_path=/etc/yum.repos.d/euleros_aarch64.repo \
    && rm -f /etc/yum.repos.d/euleros*.repo \
    && echo "[base]" > ${repo_path} \
    && echo "name=EulerOS-2.0SP8 base" >> ${repo_path} \
    && echo "baseurl=http://59.36.11.51/productrepo/repo/EulerOS_Server_V200R008C00SPC201B530/" >> ${repo_path} \
    && echo "enabled=1" >> ${repo_path} \
    && echo "gpgcheck=1" >> ${repo_path} \
    && echo "gpgkey=http://59.36.11.51/productrepo/repo/EulerOS_Server_V200R008C00SPC201B530/EulerOS_Server_V200R008C00SPC201B530/RPM-GPG-KEY-EulerOS" >> ${repo_path} \
    && yum clean all \
    && yum makecache

# Install base tools
RUN yum update \
    && yum install -y vim \
    && yum install -y wget \
    && yum install -y xz \
    && yum install -y net-tools \
    && yum install -y openssh-clients \
    && yum install -y passwd \
    && yum install -y git \
    && yum install -y curl \
    && yum install -y subversion \
    && yum install -y tar \
    && yum install -y tcl \
    && yum install -y java-1.8.0

# Install compile tools
RUN yum install -y gcc \
    && yum install -y gcc-c++ \
    && yum install -y gcc-gfortran \
    && yum install -y make \
    && yum install -y gmp-devel \
    && yum install -y patch

# Install python(root)
RUN yum install -y libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel gdbm-devel \
    && cd /tmp \
    && rm -f /tmp/Python-3.7.5.tar.xz \
#   && wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz \
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
    && rm -f /usr/local/bin/pip3 \
    && ln -s ${PYTHON_ROOT_PATH}/bin/python3.7 /usr/local/bin/python3 \
    && ln -s ${PYTHON_ROOT_PATH}/bin/pip3.7 /usr/local/bin/pip3 \
    && rm -rf /tmp/Python-3.7.5 \
    && rm -f /tmp/Python-3.7.5.tar.xz

# Set pip source(root)
RUN mkdir -pv /root/.pip \
    && echo "[global]" > /root/.pip/pip.conf \
    && echo "trusted-host=mirrors.aliyun.com" >> /root/.pip/pip.conf \
    && echo "index-url=http://mirrors.aliyun.com/pypi/simple/" >> /root/.pip/pip.conf

# Install pip package(root)
RUN echo "export PATH=${PYTHON_ROOT_PATH}/bin:\$PATH" >> ~/.bash_profile \
    && source ~/.bash_profile \
    && pip3 install numpy \
    && pip3 install wheel \
    && pip3 install nose \
    && pip3 install pytest \
    && pip3 install pytest-xdist \
    && pip3 list

# Install cmake(root)
RUN cd /tmp \
    && rm -f /tmp/cmake-3.15.5.tar.gz \
#   && wget https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5.tar.gz \
    && wget http://59.36.11.51/tools/build/cmake/cmake-3.15.5.tar.gz \
    && tar -zxf cmake-3.15.5.tar.gz \
    && cd cmake-3.15.5 \
    && ./bootstrap --prefix=/usr --parallel=4 \
    && make -j4 \
    && make install -j4 \
    && rm -rf /tmp/cmake-3.15.5 \
    && rm -f /tmp/cmake-3.15.5.tar.gz

# Install ccache
RUN cd /tmp \
    && rm -f /tmp/ccache-3.7.6.tar.gz \
#   && wget https://github.com/ccache/ccache/releases/download/v3.7.6/ccache-3.7.6.tar.gz \
    && wget http://59.36.11.51/tools/build/ccache/ccache-3.7.6.tar.gz \
    && tar -zxf ccache-3.7.6.tar.gz \
    && cd ccache-3.7.6 \
    && ./configure --prefix=/usr/local/ccache \
    && make -j4 \
    && make install -j4 \
    && rm -f /usr/local/bin/gcc \
    && rm -f /usr/local/bin/g++ \
    && rm -f /usr/local/bin/cc \
    && rm -f /usr/local/bin/c++ \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/gcc \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/g++ \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/cc \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/c++ \
    && rm -rf /tmp/ccache-3.7.6 \
    && rm -f /tmp/ccache-3.7.6.tar.gz

ARG VERSION=3.35
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent

# Create user of jenkins
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}

# Set sudo
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install python(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
#   && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/Python-3.7.5.tar.xz; wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz; tar -xf Python-3.7.5.tar.xz" \
    && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/Python-3.7.5.tar.xz; wget http://59.36.11.51/tools/build/python/Python-3.7.5.tar.xz; tar -xf Python-3.7.5.tar.xz" \
    && ${MINDSPORE_CMD} "cd /tmp/Python-3.7.5; ./configure --prefix=/home/jenkins/python375 --enable-shared && make -j4 && make install -j4" \
    && ${MINDSPORE_CMD} "cd /tmp/Python-3.7.5; ./configure --prefix=/home/jenkins/python375 && make -j4 && make install -j4" \
    && ${MINDSPORE_CMD} "rm -rf /tmp/Python-3.7.5; rm -f /tmp/Python-3.7.5.tar.xz"

# Set pip source(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
    && ${MINDSPORE_CMD} "mkdir -pv /home/jenkins/.pip; echo '[global]' > /home/jenkins/.pip/pip.conf; echo 'trusted-host=mirrors.aliyun.com' >> /home/jenkins/.pip/pip.conf; echo 'index-url=http://mirrors.aliyun.com/pypi/simple/' >> /home/jenkins/.pip/pip.conf"

# Install pip package(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
    && ${MINDSPORE_CMD} "echo 'export PATH=/home/jenkins/python375/bin:\$PATH' >> ~/.bash_profile" \
    && ${MINDSPORE_CMD} "source ~/.bash_profile; pip3 install numpy; pip3 install wheel; pip3 install nose; pip3 install pytest; pip3 install pytest-xdist; pip3 list"

# Install cmake(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
#   && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/cmake-3.15.5.tar.gz; wget https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5.tar.gz; tar -zxf cmake-3.15.5.tar.gz" \
    && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/cmake-3.15.5.tar.gz; wget http://59.36.11.51/tools/build/cmake/cmake-3.15.5.tar.gz; tar -zxf cmake-3.15.5.tar.gz" \
    && ${MINDSPORE_CMD} "cd /tmp/cmake-3.15.5; ./bootstrap --prefix=/home/jenkins/cmake --parallel=4; make -j4; make install -j4" \
    && ${MINDSPORE_CMD} "rm -rf /tmp/cmake-3.15.5; rm -f /tmp/cmake-3.15.5.tar.gz" \
    && ${MINDSPORE_CMD} "echo 'export PATH=/home/jenkins/cmake/bin:\$PATH' >> ~/.bash_profile"

# Set sshd and timezone
RUN sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config \
    && rm -f /etc/localtime \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && echo "export TZ='Asia/Shanghai'" >> /etc/profile \
    && export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
    && ${MINDSPORE_CMD} "echo export TZ='Asia/Shanghai' >> ~/.bashrc"

# Set yum source(huaweicloud)
RUN repo_path=/etc/yum.repos.d/euleros_aarch64.repo \
    && echo "[base]" > ${repo_path} \
    && echo "name=EulerOS-2.0SP8 base" >> ${repo_path} \
    && echo "baseurl=http://mirrors.huaweicloud.com/euler/2.8/os/aarch64/" >> ${repo_path} \
    && echo "enabled=1" >> ${repo_path} \
    && echo "gpgcheck=1" >> ${repo_path} \
    && echo "gpgkey=http://mirrors.huaweicloud.com/euler/2.8/os/aarch64/RPM-GPG-KEY-EulerOS" >> ${repo_path}

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
