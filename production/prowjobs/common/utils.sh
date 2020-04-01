#!/bin/sh

clone_mindspore_deploy() {
  if [ -z "$MINDSPORE_DEPLOY_USER" ]; then
    echo "MINDSPORE_DEPLOY_USER is not set"
    return 1
  fi

  if [ -z "$MINDSPORE_DEPLOY_TOKEN_PATH" ]; then
    echo "MINDSPORE_DEPLOY_TOKEN_PATH is not set "
    return 1
  fi

  if [ ! -f "$MINDSPORE_DEPLOY_TOKEN_PATH" ]; then
    echo "file($MINDSPORE_DEPLOY_TOKEN_PATH) is not a normal file"
    return 1
  fi

  token=$(cat $MINDSPORE_DEPLOY_TOKEN_PATH)
  if [ -z "$token" ]; then
    echo "can not get mindspore deploy token"
    return 1
  fi

  local out_dir=$1

  git clone https://${MINDSPORE_DEPLOY_USER}:${token}@gitee.com/mindspore/mindspore_deploy.git ${out_dir}
  if [ $? -ne 0 ]; then
    echo "Clone mindspore_deploy failed"
    return 1
  fi
}

delete_path() {
  local path=$1
  if [[ -d "$path" || -f "$path" ]]; then
    rm $path -fr
  fi
}
