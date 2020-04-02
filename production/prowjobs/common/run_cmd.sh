#!/bin/bash

# Init paramters
cmd=$1
code_path=$2

my_dir=$(dirname $0)
cd $my_dir
my_dir=$(pwd)

# Source utils
source $my_dir/utils.sh
if [ $? -ne 0 ];then
    echo "[Error] Source utils failed."
    exit 1
fi

# Clone mindspore_deploy
test -d $WORKSPACE && rm -fr $WORKSPACE
mkdir -p $WORKSPACE

err=$(clone_mindspore_deploy $MINDSPORE_DEPLOY_PATH)
if [ $? -ne 0 ]; then
  echo "[Error] $err"
  exit 1
fi

# Run job
# the cmd of `find` will output nothing when the target dir is the symbol link
# project=$(basename $code_path)
# ln -s $code_path "${WORKSPACE}/$project"
# $cmd $WORKSPACE $project $MINDSPORE_DEPLOY_PATH

$cmd "$(dirname $code_path)" "$(basename $code_path)" $MINDSPORE_DEPLOY_PATH
