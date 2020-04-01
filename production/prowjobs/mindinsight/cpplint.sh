#!/bin/sh

# Init paramters
my_dir=$(dirname $0)
workspace=/home/workspace
deploy_path=$workspace/mindspore_deploy
project_path=$GOPATH/src/github.com/mindspore-ai/mindinsight

# Source env
export PATH=/usr/local/python/python375/bin:$PATH

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

# Run cppcheck
LOG_HEAD "Run cpplint."
output=${workspace}/cpplint-style.xml
cpplint --root=src --extensions=cxx,cu,hh,cpp,hxx,cuh,h++,cc,c,hpp,c++,h --quiet --repository=${project_path} --linelength=120 --recursive ${project_path} > ${output} 2>&1
DP_ASSERT_FILE $output "check $output"

error_number=$(grep "$project_path" ${output} | wc -l)
if [ $error_number -ne 0 ]; then
  LOG_ERROR "Run cpplint failed, error number = $error_number"
  # exit 1
fi
