#!/bin/bash

# Init paramters
my_dir=$(dirname $0)
cd $my_dir
my_dir=$(pwd)

source $my_dir/common.sh

${my_dir}/../common/run_cmd.sh "${my_dir}/../jobs/$(basename $0)" "$CODE_PATH"
