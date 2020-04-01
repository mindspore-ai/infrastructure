#!/bin/bash

# Init parameters
workspace=$1
project_name=$2
deploy_path=$3
pylintrc_path="${deploy_path}/common/rules/pylint"

# Set exclude folder
if [ "${project_name}" = "mindspore" ]; then
    exclude_folder="mindspore/third_party|mindspore/tests"
fi

# Source env
export PATH=/usr/local/python/python375/bin:$PATH

# Source common-env
source ${deploy_path}/common/scripts/common/common-lib.sh
if [ $? -ne 0 ]; then
    echo "[ERROR] Source common-lib is failed."
    exit 1
fi

# Copy code
LOG_HEAD "Check code of ${project_name}."
DP_ASSERT_DIRECTORY "${workspace}/${project_name}" "Check ${project_name}"

# Get scan filename
LOG_HEAD "Print file number."
cd ${workspace}
(find ${project_name} -iname "*.py"|egrep -v "${exclude_folder}") > ${workspace}/scan_filename.txt
file_number=$(cat ${workspace}/scan_filename.txt|wc -l)
echo "File number: ${file_number}"

# Run pylint
LOG_HEAD "Run pylint."
cd ${workspace}
(find ${project_name} -iname "*.py"|egrep -v "${exclude_folder}")|xargs pylint --rcfile=${pylintrc_path}/pylintrc -j 2 --output-format=parseable > ${workspace}/pylint.log
DP_ASSERT_FILE "${workspace}/pylint.log" "Run pylint"

# Filter
LOG_HEAD "Filter..."
cd ${deploy_path}/common/scripts/pylint
sh filter_pylint.sh "${workspace}" "${project_name}"

# Print content
LOG_HEAD "Problem: "
cat ${workspace}/pylint.log|grep "^mindspore/"

# Return result
error_number=$(cat ${workspace}/pylint.log|grep "^mindspore/"|wc -l)
LOG_HEAD "Pylint error number: ${error_number}"
if [ "${project_name}" = "mindspore" ]; then
    DP_ASSERT_EQUAL "${error_number}" "0" "Pylint scanning"
fi
