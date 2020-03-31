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

# Run shellcheck (warning)

target_files() {
  find ${project_path} -iname "*.sh" -type f
}

LOG_HEAD "Run shellcheck(warning && error)."
warning_number=$(target_files | xargs shellcheck --severity=warning --format=gcc | wc -l)
LOG_INFO "Shellcheck warning number: ${warning_number}"

output=${workspace}/shellcheck_result.log
target_files | xargs shellcheck --severity=warning --format=tty > $output
DP_ASSERT_FILE $output "check $output"

cat ${output}
