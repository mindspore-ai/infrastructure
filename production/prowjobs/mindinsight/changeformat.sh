#!/bin/sh

# Init paramters
my_dir=$(dirname $0)
workspace=/home/workspace
deploy_path=$workspace/mindspore_deploy
project_path=$GOPATH/src/github.com/mindspore-ai/mindinsight

# Source env
export PATH=/usr/local/python/python375/bin:/usr/local/clang-format/bin:$PATH

# Source utils
cd $my_dir/../common
source $(pwd)/utils.sh
if [ $? -ne 0 ];then
    echo "[Error] Source utils failed."
    exit 1
fi
cd $my_dir

# Clone mindspore_deploy
test -d $workspace || mkdir -p $workspace

err=$(clone_mindspore_deploy $deploy_path)
if [ $? -ne 0 ]; then
  echo "[Error] $err"
  exit 1
fi

# Source common-env
source ${deploy_path}/common/scripts/common/common-lib.sh
if [ $? -ne 0 ];then
    echo "[Error] Source common-lib is failed."
    exit 1
fi

# Exclude folder
exclude_folder="tests,third_party,graphengine"
LOG_HEAD "Exclude folder(${exclude_folder})."

for folder in ${exclude_folder//,/ }; do
    delete_path "${project_path}/${folder}"
done

# Check clang-format
LOG_HEAD "Check clang-format."
cd $project_path
bash -x scripts/check_clang_format.sh -l
DP_ASSERT_EQUAL "$?" "0" "Check clang-format"
