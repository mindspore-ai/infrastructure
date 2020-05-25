#!/bin/bash

# Global parameter
IMAGE_VERSION="0.0.1"
WORKSPACE=$(dirname "${BASH_SOURCE-$0}")
WORKSPACE=$(cd -P "${WORKSPACE}"; pwd -P)

# Set yum source
yum_path=/etc/yum.repos.d/euleros_aarch64.repo
echo "[base]" > ${yum_path}
echo "name=EulerOS-2.0SP8 base" >> ${yum_path}
echo "baseurl=http://mirrors.huaweicloud.com/euler/2.8/os/aarch64/" >> ${yum_path}
echo "enabled=1" >> ${yum_path}
echo "gpgcheck=1" >> ${yum_path}
echo "gpgkey=http://mirrors.huaweicloud.com/euler/2.8/os/aarch64/RPM-GPG-KEY-EulerOS" >> ${yum_path}
yum clean all
yum makecache

# Install docker
yum install -y docker-engine

# Docker build
docker build -t mindspore_euleros_aarch64:${IMAGE_VERSION} ${WORKSPACE}

# Docker push
docker tag mindspore_euleros_aarch64:${IMAGE_VERSION} swr.cn-north-4.myhuaweicloud.com/mindspore/mindspore_euleros_aarch64:${IMAGE_VERSION}
docker push swr.cn-north-4.myhuaweicloud.com/mindspore/mindspore_euleros_aarch64:${IMAGE_VERSION}
