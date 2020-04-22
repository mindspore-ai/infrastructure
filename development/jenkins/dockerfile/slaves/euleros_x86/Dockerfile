# Base image euleros:2.5
FROM swr.cn-north-1.myhuaweicloud.com/mindspore/euleros_x86:2.5
MAINTAINER tommylike <tommylikehu@gmail.com>

# Set env
USER root
ENV USER root
ENV PATH /usr/local/bin:$PATH
ENV PYTHON_ROOT_PATH /usr/local/python/python375

# Set yum source
RUN repo_path=/etc/yum.repos.d/euleros.repo \
    && rm -f /etc/yum.repos.d/euleros*.repo \
    && echo "[base]" > ${repo_path} \
    && echo "name=EulerOS-2.0SP5 base" >> ${repo_path} \
    && echo "baseurl=http://dev-thirdparty.mindspore.cn:8081/productrepo/repo/EulerOS-V2.0SP5-x86_64-dvd-20190709/" >> ${repo_path} \
    && echo "enabled=1" >> ${repo_path} \
    && echo "gpgcheck=1" >> ${repo_path} \
    && echo "gpgkey=http://dev-thirdparty.mindspore.cn:8081/productrepo/repo/EulerOS-V2.0SP5-x86_64-dvd-20190709/RPM-GPG-KEY-EulerOS" >> ${repo_path} \
    && yum clean all \
    && yum makecache

# Install base tools
RUN rpm --rebuilddb \
    && yum update \
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
    && yum install -y bzip2 \
    && yum install -y tcl \
    && yum install -y sudo \
    && yum install -y libSM \
    && yum install -y libjpeg-turbo-devel \
    && yum install -y freetype-devel \
    && yum install -y blas \
    && yum install -y lapack \
    && yum install -y automake \
    && yum install -y autoconf \
    && yum install -y libtool \
    && yum install -y java-1.8.0

# Install compile tools
RUN rpm --rebuilddb \
    && yum install -y gcc \
    && yum install -y gcc-c++ \
    && yum install -y gcc-gfortran \
    && yum install -y make \
    && yum install -y gmp-devel \
    && yum install -y patch

# Install gcc-7.3.0(root)
RUN cd /tmp \
    && rm -f gcc-7.3.0-euleros2.5-Linux-x86_64.run \
    && wget http://dev-thirdparty.mindspore.cn:8081/tools/build/gcc/gcc-7.3.0/bin/gcc-7.3.0-euleros2.5-Linux-x86_64/gcc-7.3.0-euleros2.5-Linux-x86_64.run \
    && mkdir -pv /usr/local/gcc \
    && bash gcc-7.3.0-euleros2.5-Linux-x86_64.run /usr/local/gcc \
    && rm -f /tmp/gcc-7.3.0-euleros2.5-Linux-x86_64.run

# Set gcc env
ENV PATH /usr/local/gcc/gcc730/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/gcc/gcc730/lib64:$LD_LIBRARY_PATH

# Install python(root)
RUN rpm --rebuilddb \
    && yum install -y libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel \
    && cd /tmp \
    && rm -f /tmp/Python-3.7.5.tar.xz \
#   && wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz 
    && wget http://dev-thirdparty.mindspore.cn:8081/tools/build/python/Python-3.7.5.tar.xz \
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
RUN mkdir -pv /root/.pip \
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
    && wget http://dev-thirdparty.mindspore.cn:8081/tools/build/cmake/cmake-3.14.1.tar.gz \
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
    && wget https://mirrors.huaweicloud.com/nodejs/v10.19.0/node-v10.19.0-linux-x64.tar.gz \
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
    && wget http://dev-thirdparty.mindspore.cn:8081/tools/build/ccache/ccache-3.7.7.tar.gz \
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
    && ${MINDSPORE_CMD} "cd /tmp; rm -f gcc-7.3.0-euleros2.5-Linux-x86_64.run; wget http://dev-thirdparty.mindspore.cn:8081/tools/build/gcc/gcc-7.3.0/bin/gcc-7.3.0-euleros2.5-Linux-x86_64/gcc-7.3.0-euleros2.5-Linux-x86_64.run" \
    && ${MINDSPORE_CMD} "cd /tmp; mkdir -pv /home/jenkins/tools/gcc; bash gcc-7.3.0-euleros2.5-Linux-x86_64.run /home/jenkins/tools/gcc" \
    && ${MINDSPORE_CMD} "rm -f /tmp/gcc-7.3.0-euleros2.5-Linux-x86_64.run"

# Install python(jenkins)
RUN export MINDSPORE_CMD="su jenkins -s /bin/bash -c " \
#   && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/Python-3.7.5.tar.xz; wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz; tar -xf Python-3.7.5.tar.xz" 
    && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/Python-3.7.5.tar.xz; wget http://dev-thirdparty.mindspore.cn:8081/tools/build/python/Python-3.7.5.tar.xz; tar -xf Python-3.7.5.tar.xz" \
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
    && ${MINDSPORE_CMD} "cd /tmp; rm -f /tmp/cmake-3.14.1.tar.gz; wget http://dev-thirdparty.mindspore.cn:8081/tools/build/cmake/cmake-3.14.1.tar.gz; tar -zxf cmake-3.14.1.tar.gz" \
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

# Set yum source(huaweicloud)
RUN repo_path=/etc/yum.repos.d/euleros.repo \
    && echo "[base]" > ${repo_path} \
    && echo "name=EulerOS-2.0SP5 base" >> ${repo_path} \
    && echo "baseurl=http://repo.huaweicloud.com/euler/2.5/os/x86_64/" >> ${repo_path} \
    && echo "enabled=1" >> ${repo_path} \
    && echo "gpgcheck=1" >> ${repo_path} \
    && echo "gpgkey=http://repo.huaweicloud.com/euler/2.5/os/RPM-GPG-KEY-EulerOS" >> ${repo_path}

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
