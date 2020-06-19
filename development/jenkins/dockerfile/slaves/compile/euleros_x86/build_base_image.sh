#!/bin/bash

# Global parameter
WORKSPACE=`dirname "${BASH_SOURCE-$0}"`
WORKSPACE=`cd -P "${WORKSPACE}"; pwd -P`
MOUNT_PATH="/mnt/iso/euleros25"
IMAGE_VERSION="2.5.20190709"

# Download code
echo "[INFO] Git clone code of euleros-docker-images."
cd ${WORKSPACE}
git clone https://github.com/euleros/euleros-docker-images.git
cd ${WORKSPACE}/euleros-docker-images
git checkout c60e36eb76d8a260c76d5b8e7d8b5c544e8f6d23

# Download ISO
echo "[INFO] Download ISO."
cd ${WORKSPACE}
if [ ! -f ${WORKSPACE}/EulerOS-V2.0SP5-x86_64-dvd.iso ]; then
    #wget http://tools.mindspore.cn/productrepo/iso/euleros/EulerOS-V2.0SP5-x86_64-dvd-20190709/EulerOS-V2.0SP5-x86_64-dvd.iso
    wget https://euleros2019.obs.cn-north-1.myhuaweicloud.com/ict/site-euleros/euleros/repo/yum/2.5/os/x86_64/iso/EulerOS-V2.0SP5-x86_64-dvd.iso
fi

# Mount ISO
echo "[INFO] Mount ISO."
mkdir -p ${MOUNT_PATH}
mount -t iso9660 -o loop ${WORKSPACE}/EulerOS-V2.0SP5-x86_64-dvd.iso ${MOUNT_PATH}

# Generate base image
echo "[INFO] Generate base image."
export OS_VERSION=2.5
export ISO_PATH=${MOUNT_PATH}
export RPM_ROOT=${WORKSPACE}/euleros-docker-images/scripts/rootfs
cd ${WORKSPACE}/euleros-docker-images/scripts
bash generate.sh

# Import base image
echo "[INFO] Import base image."
docker images|grep "base_euleros_x86"|grep "${IMAGE_VERSION}"
if [ $? -ne 0 ]; then
    cat ${WORKSPACE}/euleros-docker-images/scripts/x86_64/EulerOS-2.5-x86_64.tar.xz|docker import - base_euleros_x86:${IMAGE_VERSION}
fi

# Docker push
echo "[INFO] Dock push."
docker tag base_euleros_x86:${IMAGE_VERSION} swr.cn-north-4.myhuaweicloud.com/mindspore/base_euleros_x86:${IMAGE_VERSION}
docker push swr.cn-north-4.myhuaweicloud.com/mindspore/base_euleros_x86:${IMAGE_VERSION}
