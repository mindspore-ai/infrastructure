#!/bin/bash

# Init paramters
my_dir=$(dirname $0)

# Source utils
cd $my_dir
source ../common/utils.sh
if [ $? -ne 0 ];then
    echo "[Error] Source utils failed."
    exit 1
fi

# Clone mindspore_deploy
test -d $WORKSPACE || mkdir -p $WORKSPACE

err=$(clone_mindspore_deploy $MINDSPORE_DEPLOY_PATH)
if [ $? -ne 0 ]; then
  echo "[Error] $err"
  exit 1
fi

${my_dir}/../jobs/clang_format.sh $GOPATH/src/github.com/mindspore-ai mindinsight $MINDSPORE_DEPLOY_PATH
