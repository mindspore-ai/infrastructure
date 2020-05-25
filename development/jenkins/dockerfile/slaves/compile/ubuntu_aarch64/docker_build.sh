#!/bin/bash

# Global parameter
IMAGE_VERSION="0.0.1"
WORKSPACE=$(dirname "${BASH_SOURCE-$0}")
WORKSPACE=$(cd -P "${WORKSPACE}"; pwd -P)

# Install docker
apt install -y docker.io

# Docker build
docker build -t mindspore_ubuntu_aarch64:${IMAGE_VERSION} ${WORKSPACE}

# Docker push
docker tag mindspore_ubuntu_aarch64:${IMAGE_VERSION} swr.cn-north-4.myhuaweicloud.com/mindspore/mindspore_ubuntu_aarch64:${IMAGE_VERSION}
docker push swr.cn-north-4.myhuaweicloud.com/mindspore/mindspore_ubuntu_aarch64:${IMAGE_VERSION}
