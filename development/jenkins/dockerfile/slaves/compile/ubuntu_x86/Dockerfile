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
ENV PATH /usr/local/gcc/gcc730/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/gcc/gcc730/lib64:$LD_LIBRARY_PATH
ARG PYTHON_PATH=/usr/local/python/python375
ENV PATH ${PYTHON_PATH}/bin:$PATH
ENV LD_LIBRARY_PATH ${PYTHON_PATH}/lib:$LD_LIBRARY_PATH
ENV PATH /usr/local/cmake/bin:$PATH
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
    make \
    libgmp-dev \
    patch \
    autoconf \
    libtool \
    automake \
    flex

# Install dependency lib of python
RUN DEBIAN_FRONTEND=noninteractive apt install -y libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libncurses5-dev \
    libgdbm-dev \
    liblzma-dev \
    libreadline-dev

# Install dependency lib of opencv-python(pip)
RUN DEBIAN_FRONTEND=noninteractive apt install -y libsm6

# Install dependency lib of pillow(pip)
RUN DEBIAN_FRONTEND=noninteractive apt install -y libjpeg-dev

# Install dependency lib of matplotlib(pip)
RUN DEBIAN_FRONTEND=noninteractive apt install -y libfreetype6-dev

# Install dependency lib of scipy(pip)
RUN DEBIAN_FRONTEND=noninteractive apt install -y libblas-dev \
    liblapack-dev \
    libopenblas-dev \
    libatlas-base-dev

# Install gcc
RUN mkdir -p /tmp/gcc \
    && cd /tmp/gcc \
    && wget https://mirrors.ustc.edu.cn/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz \
    && wget https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2 \
    && wget https://mirrors.ustc.edu.cn/gnu/gmp/gmp-6.1.0.tar.bz2 \
    && wget https://mirrors.ustc.edu.cn/gnu/mpfr/mpfr-3.1.4.tar.gz \
    && wget https://mirrors.ustc.edu.cn/gnu/mpc/mpc-1.0.3.tar.gz \
    && tar -zxf gcc-7.3.0.tar.gz \
    && tar -zxf mpc-1.0.3.tar.gz \
    && tar -zxf mpfr-3.1.4.tar.gz \
    && tar -jxf gmp-6.1.0.tar.bz2 \
    && tar -jxf isl-0.16.1.tar.bz2 \
    && mv gmp-6.1.0 gcc-7.3.0/gmp \
    && mv isl-0.16.1 gcc-7.3.0/isl \
    && mv mpc-1.0.3 gcc-7.3.0/mpc \
    && mv mpfr-3.1.4 gcc-7.3.0/mpfr \
    && mkdir -p /usr/local/gcc/gcc730 \
    && cd /tmp/gcc/gcc-7.3.0 \
    && mkdir build \
    && cd build \
    && ../configure --prefix=/usr/local/gcc/gcc730 -enable-checking=release -enable-languages=c,c++ -disable-multilib \
    && make -j8 \
    && make install-strip \
    && chmod 755 -R /usr/local/gcc \
    && cd /usr/local/gcc/gcc730/bin \
    && ln -s gcc cc \
    && rm -rf /tmp/gcc

# Install python
RUN umask 022 \
    && cd /tmp \
    && wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz \
    && tar -xf Python-3.7.5.tar.xz \
    && cd /tmp/Python-3.7.5 \
    && ./configure --prefix=${PYTHON_PATH} --enable-shared \
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

# Install cmake
RUN cd /tmp \
    && wget https://github.com/Kitware/CMake/releases/download/v3.14.1/cmake-3.14.1.tar.gz \
    && tar -zxf cmake-3.14.1.tar.gz \
    && cd cmake-3.14.1 \
    && ./bootstrap --prefix=/usr/local/cmake --parallel=8 \
    && make -j8 \
    && make install -j8 \
    && chmod 755 -R /usr/local/cmake \
    && rm -rf /tmp/cmake-3.14.1 \
    && rm -f /tmp/cmake-3.14.1.tar.gz

# Install nodejs
RUN cd /tmp \
    && wget https://mirrors.huaweicloud.com/nodejs/v10.19.0/node-v10.19.0-linux-x64.tar.gz \
    && tar -zxf node-v10.19.0-linux-x64.tar.gz \
    && rm -rf /usr/local/nodejs \
    && mkdir -p /usr/local/nodejs \
    && mv /tmp/node-v10.19.0-linux-x64 /usr/local/nodejs/ \
    && chmod 755 -R /usr/local/nodejs \
    && ln -sf /usr/local/nodejs/node-v10.19.0-linux-x64/bin/node /usr/bin/node \
    && ln -sf /usr/local/nodejs/node-v10.19.0-linux-x64/bin/npm /usr/bin/npm \
    && npm config set registry https://mirrors.huaweicloud.com/repository/npm/ \
    && rm -f /tmp/node-v10.19.0-linux-x64.tar.gz

# Install ccache
RUN cd /tmp \
    && wget https://github.com/ccache/ccache/releases/download/v3.7.9/ccache-3.7.9.tar.gz \
    && tar -zxf ccache-3.7.9.tar.gz \
    && cd ccache-3.7.9 \
    && ./configure --prefix=/usr/local/ccache \
    && make -j8 \
    && make install -j8 \
    && chmod 755 -R /usr/local/ccache \
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
    && rm -rf /tmp/ccache-3.7.9 \
    && rm -f /tmp/ccache-3.7.9.tar.gz

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
ENV PATH /home/${user}/.local/bin:/home/${user}/bin:$PATH
RUN echo "export TZ='Asia/Shanghai'" >> ~/.bashrc \
    && mkdir -p /home/${user}/.jenkins \
    && mkdir -p ${AGENT_WORKDIR}

# Install pip package
RUN pip3 install --user pytest \
    && pip3 install --user pytest-xdist \
    && pip3 install --user 'setuptools>=40.8.0' \
    && pip3 install --user 'wheel>=0.32.0' \
    && pip3 install --user 'numpy>=1.17.0' \
    && pip3 install --user 'pillow>=6.2.0' \
    && pip3 install --user 'protobuf>=3.8.0' \
    && pip3 install --user 'asttokens>=1.1.13' \
    && pip3 install --user 'scipy==1.3.3' \
    && pip3 install --user 'easydict>=1.9' \
    && pip3 install --user 'sympy>=1.4' \
    && pip3 install --user 'cffi>=1.13.2' \
    && pip3 install --user 'decorator>=4.4.0' \
    && pip3 install --user 'matplotlib>=3.1.3' \
    && pip3 install --user 'opencv-python>=4.2.0.32' \
    && pip3 install --user 'pybind11>=2.4.3' \
    && pip3 install --user 'attrdict>=2.0.1' \
    && pip3 install --user 'Click>=7.0' \
    && pip3 install --user 'Flask>=1.1.1' \
    && pip3 install --user 'Flask-Cors>=3.0.8' \
    && pip3 install --user 'gunicorn>=19.9.0' \
    && pip3 install --user 'itsdangerous>=1.1.0' \
    && pip3 install --user 'Jinja2>=2.10.1' \
    && pip3 install --user 'MarkupSafe>=1.1.1' \
    && pip3 install --user 'marshmallow>=2.19.2' \
    && pip3 install --user 'psutil>=5.6.1' \
    && pip3 install --user 'six>=1.12.0' \
    && pip3 install --user 'Werkzeug>=1.0.0' \
    && pip3 list

# Clear cache
RUN rm -rf /home/${user}/.cache/pip \
    && /usr/local/ccache/bin/ccache -C

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}
ENTRYPOINT ["jenkins-agent"]
