# Base image
FROM swr.cn-north-4.myhuaweicloud.com/mindspore/base_euleros_aarch64:2.8.C00SPC201B530
MAINTAINER tommylike <tommylikehu@gmail.com>

##############
# User: root #
##############
# Set env
USER root
ENV USER root
ENV PATH /usr/local/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/jre
ENV PATH $PATH:$JAVA_HOME/bin
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

# Set yum source
RUN repo_path=/etc/yum.repos.d/euleros_aarch64.repo \
    && rm -f /etc/yum.repos.d/euleros*.repo \
    && echo "[base]" > ${repo_path} \
    && echo "name=EulerOS-2.0SP8 base" >> ${repo_path} \
    && echo "baseurl=https://tools.mindspore.cn/productrepo/repo/euleros/aarch64/EulerOS_Server_V200R008C00SPC201B530/" >> ${repo_path} \
    && echo "enabled=1" >> ${repo_path} \
    && echo "gpgcheck=1" >> ${repo_path} \
    && echo "gpgkey=https://tools.mindspore.cn/productrepo/repo/euleros/aarch64/EulerOS_Server_V200R008C00SPC201B530/RPM-GPG-KEY-EulerOS" >> ${repo_path} \
    && yum clean all \
    && yum makecache \
    && yum update

# Install base tools
RUN yum install -y vim \
    wget \
    xz \
    net-tools \
    openssh-clients \
    git \
    curl \
    subversion \
    ntpdate \
    unzip \
    tzdata \
    tcl \
    sudo \
    bzip2 \
    passwd \
    tar \
    java-1.8.0

# Install compile tools
RUN yum install -y gcc \
    gcc-c++ \
    gcc-gfortran \
    make \
    gmp-devel \
    patch \
    autoconf \
    libtool \
    automake

# Install dependency lib of python
RUN yum install -y libffi-devel \ 
    zlib-devel \
    bzip2-devel \
    openssl-devel \
    ncurses-devel \
    sqlite-devel \
    readline-devel \
    gdbm-devel

# Install dependency lib of opencv-python(pip)
RUN yum install -y libSM

# Install dependency lib of pillow(pip)
RUN yum install -y libjpeg-turbo-devel

# Install dependency lib of matplotlib(pip)
RUN yum install -y freetype-devel

# Install dependency lib of scipy(pip)
RUN yum install -y blas \
    lapack \
    openblas \
    atlas \
    atlas-devel

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
    && wget https://mirrors.huaweicloud.com/nodejs/v10.19.0/node-v10.19.0-linux-arm64.tar.gz \
    && tar -zxf node-v10.19.0-linux-arm64.tar.gz \
    && rm -rf /usr/local/nodejs \
    && mkdir -p /usr/local/nodejs \
    && mv /tmp/node-v10.19.0-linux-arm64 /usr/local/nodejs/ \
    && chmod 755 -R /usr/local/nodejs \
    && ln -sf /usr/local/nodejs/node-v10.19.0-linux-arm64/bin/node /usr/bin/node \
    && ln -sf /usr/local/nodejs/node-v10.19.0-linux-arm64/bin/npm /usr/bin/npm \
    && npm config set registry https://mirrors.huaweicloud.com/repository/npm \
    && rm -f /tmp/node-v10.19.0-linux-arm64.tar.gz

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

# Set pip source
RUN mkdir -p /home/${user}/.pip \
    && echo "[global]" > /home/${user}/.pip/pip.conf \
    && echo "index-url=https://repo.huaweicloud.com/repository/pypi/simple" >> /home/${user}/.pip/pip.conf \
    && echo "trusted-host=repo.huaweicloud.com" >> /home/${user}/.pip/pip.conf \
    && echo "timeout=120" >> /home/${user}/.pip/pip.conf

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
