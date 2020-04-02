#!/bin/bash

# Init parameters
workspace=$1
project_name=$2
deploy_path=$3

# Set exclude folder
if [ "${project_name}" = "mindspore" ]; then
    exclude_folder="tests,third_party"
fi

# Source common-env
source ${deploy_path}/common/scripts/common/common-lib.sh
if [ $? -ne 0 ];then
    echo "[ERROR] Source common-lib is failed."
    exit 1
fi

# Copy code
LOG_HEAD "Check code of ${project_name}."
DP_ASSERT_DIRECTORY "${workspace}/${project_name}" "Check ${project_name}"

# Exclude folder
LOG_HEAD "Exclude folder(${exclude_folder})."
for folder in ${exclude_folder//,/ }; do
    rm -rf ${workspace}/${project_name}/${folder}
done
ls -la ${workspace}/${project_name}

# Run shellcheck (warning)
LOG_HEAD "Run shellcheck(warning && error)."
find ${workspace}/${project_name} -name "*.sh" -type f|xargs shellcheck --severity=warning --format=tty > ${workspace}/shellcheck_result.log
DP_ASSERT_FILE "${workspace}/shellcheck_result.log" "Run shellcheck"

# Return result
warning_number=$(find ${workspace}/${project_name} -name "*.sh" -type f|xargs shellcheck --severity=warning --format=gcc|wc -l)
LOG_HEAD "Shellcheck warning number: ${warning_number}"
DP_ASSERT_EQUAL "${warning_number}" "0" "Shellcheck scanning" "${workspace}/shellcheck_result.log"
