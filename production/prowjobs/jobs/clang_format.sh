#!/bin/bash

# Init parameters
workspace=$1
project_name=$2
deploy_path=$3

# Source env
export PATH=/usr/local/clang-format/bin:$PATH

# Source common-env
source ${deploy_path}/common/scripts/common/common-lib.sh
if [ $? -ne 0 ]; then
    echo "[ERROR] Source common-lib is failed."
    exit 1
fi

# Copy code
LOG_HEAD "Check code of ${project_name}."
DP_ASSERT_DIRECTORY "${workspace}/${project_name}" "Check ${project_name}"

# Check clang-format
LOG_HEAD "Check clang-format."
cd ${workspace}/${project_name}
bash -x scripts/check_clang_format.sh -l
DP_ASSERT_EQUAL "$?" "0" "Check clang-format"
