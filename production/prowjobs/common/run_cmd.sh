#!/bin/bash

# Init paramters
cmd=$1
code_path=$2

my_dir=$(dirname $0)
cd $my_dir
my_dir=$(pwd)

# Check cmd
rcmd="${my_dir}/../jobs/$cmd"
if [ ! -f "$rcmd" ]; then
    echo "[Error] cmd($cmd) is unknown."
    exit 1
fi

# Source utils
source $my_dir/utils.sh
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

$rcmd "$(dirname $code_path)" "$(basename $code_path)" $MINDSPORE_DEPLOY_PATH
