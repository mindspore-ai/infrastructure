FROM ubuntu:xenial
MAINTAINER tommylike <tommylikehu@gmail.com>

# Install jdk8 and bunch of build tools
USER root
ENV USER root
RUN apt update \
	&& apt install -y wget curl git subversion\
	&& apt install -y openjdk-8-jdk openjfx maven vim build-essential

# Install nodejs related tools
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install -y nodejs

# Install gcc
RUN apt install -y software-properties-common && add-apt-repository ppa:ubuntu-toolchain-r/test && apt update && apt install g++-7 -y

# Install python, pip and doxygen
RUN apt install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa && \
    apt update -y && apt install -y python3.7 python3.7-dev && \
    rm /usr/bin/python3 && ln -s /usr/bin/python3.7 /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip install -U sphinx && \
    curl -o doxygen-1.8.16.tar.gz https://nchc.dl.sourceforge.net/project/doxygen/rel-1.8.16/doxygen-1.8.16.linux.bin.tar.gz &&\
    tar -xvf doxygen-1.8.16.tar.gz && \
    cp doxygen-1.8.16/bin/* /usr/bin && rm -rf doxygen-1.8.16.tar.gz && rm -rf doxygen-1.8.16 && apt clean

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
