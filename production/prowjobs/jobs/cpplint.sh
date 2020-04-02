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
DP_ASSERT_DIRECTORY "${workspace}/${project_name}" "Check ${project_name}"

# Exclude folder
LOG_HEAD "Exclude folder(${exclude_folder})."
for folder in ${exclude_folder//,/ }; do
    rm -rf ${workspace}/${project_name}/${folder}
done
ls -la ${workspace}/${project_name}

# Run cpplint(Filter rules: --filter=-whitespace)
LOG_HEAD "Run cpplint."
cd ${workspace}
cpplint --root=src --extensions=cxx,cu,hh,cpp,hxx,cuh,h++,cc,c,hpp,c++,h --filter=-build/header_guard --quiet --repository=${workspace}/${project_name} --linelength=120 --recursive ${workspace}/${project_name} > ${workspace}/cpplint-style.xml 2>&1
DP_ASSERT_FILE "${workspace}/cpplint-style.xml" "Run cpplint"

# Filter
LOG_HEAD "Filter..."
cd ${deploy_path}/common/scripts/cpplint
sh filter_cpplint.sh "${workspace}" "${project_name}"

# Print content
LOG_HEAD "Problem: "
cat ${workspace}/cpplint-style.xml|grep "^${workspace}"

# Return result
error_number=$(cat ${workspace}/cpplint-style.xml|grep "^${workspace}"|wc -l)
LOG_HEAD "Cpplint error number: ${error_number}"
if [ "${project_name}" = "mindspore" ]; then
DP_ASSERT_EQUAL "${error_number}" "0" "Cpplint scanning"
fi
