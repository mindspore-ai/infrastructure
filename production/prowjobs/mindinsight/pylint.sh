#!/bin/sh

# Init paramters
my_dir=$(dirname $0)
workspace=/home/workspace
deploy_path=$workspace/mindspore_deploy
project_path=$GOPATH/src/github.com/TommyLike/mindspore

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

# Get scan filename

target_files() {
  find ${project_path} -iname "*.py"
}

LOG_HEAD "Print file number."
LOG_INFO "File number: $(target_files | wc -l)"

# Run pylint
LOG_HEAD "Run pylint."
pylintrc_path="${deploy_path}/common/rules/pylint/pylintrc"
output=${workspace}/pylint.log
target_files | xargs pylint --rcfile=${pylintrc_path} -j 2 --output-format=parseable > $output
DP_ASSERT_FILE "$output" "check $output"

error_number=$(grep "^mindspore/" ${output} | wc -l)
if [ $error_number -ne 0 ]; then
  LOG_ERROR "Run pylint failed, error number = $error_number"
  # exit 1
fi
