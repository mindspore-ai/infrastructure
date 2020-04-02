#!/bin/bash

# Init parameters
workspace=$1
project_name=$2
deploy_path=$3

# Set exclude folder
if [ "${project_name}" = "mindspore" ]; then
    exclude_folder="tests,third_party"
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

# Exclude folder
LOG_HEAD "Exclude folder(${exclude_folder})."
for folder in ${exclude_folder//,/ }; do
    rm -rf ${workspace}/${project_name}/${folder}
done
ls -la ${workspace}/${project_name}

# Run cppcheck
LOG_HEAD "Run cppcheck."
cd ${workspace}
cppcheck --enable=style --xml --inline-suppr --force --xml-version=2 ${workspace}/${project_name} 2> ${workspace}/cppcheck-style.xml
DP_ASSERT_FILE "${workspace}/cppcheck-style.xml" "Run cppcheck"

# Filter
LOG_HEAD "Filter..."
cd ${deploy_path}/common/scripts/cppcheck
sh filter_cppcheck.sh "${workspace}" "${project_name}"

# Print content
LOG_HEAD "Problem: "
cat ${workspace}/cppcheck-style.xml

# Return result
error_number=$(grep "<error id=" ${workspace}/cppcheck-style.xml|wc -l)
LOG_HEAD "Cppcheck error number: ${error_number}"
if [ "${project_name}" = "mindspore" ]; then
DP_ASSERT_EQUAL "${error_number}" "0" "Cppcheck scanning"
fi
