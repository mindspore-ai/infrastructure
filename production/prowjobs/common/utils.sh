#!/bin/sh

clone_mindspore_deploy() {
  local out_dir=$1
  git clone https://${MINDSPORE_DEPLOY_USER}:${MINDSPORE_DEPLOY_TOKEN}@gitee.com/mindspore/mindspore_deploy.git ${out_dir}
  if [ $? -ne 0 ]; then
    echo "Clone mindspore_deploy failed"
    return 1
  fi
}

delete_path() {
  local path=$1
  if [ -d $path || -f $path ]; then
    rm $path -fr
  fi
}
