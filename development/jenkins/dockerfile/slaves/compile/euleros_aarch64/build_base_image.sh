#!/bin/bash

# Global parameter
WORKSPACE=`dirname "${BASH_SOURCE-$0}"`
WORKSPACE=`cd -P "${WORKSPACE}"; pwd -P`
MOUNT_PATH="/mnt/iso/euleros28"
IMAGE_VERSION="2.8.C00SPC201B530"

# Download code
echo "[INFO] Git clone code of euleros-docker-images."
cd ${WORKSPACE}
git clone https://github.com/euleros/euleros-docker-images.git
cd ${WORKSPACE}/euleros-docker-images
git checkout c60e36eb76d8a260c76d5b8e7d8b5c544e8f6d23

# Download ISO
echo "[INFO] Download ISO."
cd ${WORKSPACE}
if [ ! -f ${WORKSPACE}/EulerOS-V2.0SP8-aarch64-dvd.iso ]; then
    wget https://tools.mindspore.cn/productrepo/iso/euleros/EulerOS_Server_V200R008C00SPC201B530/EulerOS-V2.0SP8-aarch64-dvd.iso
fi

# Mount ISO
echo "[INFO] Mount ISO."
mkdir -p ${MOUNT_PATH}
mount -t iso9660 -o loop ${WORKSPACE}/EulerOS-V2.0SP8-aarch64-dvd.iso ${MOUNT_PATH}

# Generate base image
echo "[INFO] Generate base image."
export OS_VERSION=2.8
export ISO_PATH=${MOUNT_PATH}
export RPM_ROOT=${WORKSPACE}/euleros-docker-images/scripts/rootfs
cd ${WORKSPACE}/euleros-docker-images/scripts
bash generate.sh

# Import base image
echo "[INFO] Import base image."
docker images|grep "base_euleros_aarch64"|grep "${IMAGE_VERSION}"
if [ $? -ne 0 ]; then
    cat ${WORKSPACE}/euleros-docker-images/scripts/aarch64/EulerOS-2.8-aarch64.tar.xz|docker import - base_euleros_aarch64:${IMAGE_VERSION}
fi

# Docker push
echo "[INFO] Dock push."
docker tag base_euleros_aarch64:${IMAGE_VERSION} swr.cn-north-4.myhuaweicloud.com/mindspore/base_euleros_aarch64:${IMAGE_VERSION}
docker push swr.cn-north-4.myhuaweicloud.com/mindspore/base_euleros_aarch64:${IMAGE_VERSION}
