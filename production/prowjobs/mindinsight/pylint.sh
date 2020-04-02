#!/bin/bash

# Init paramters
my_dir=$(dirname $0)
cd $my_dir
my_dir=$(pwd)

${my_dir}/../common/run_cmd.sh $(basename $0) "$GOPATH/src/github.com/mindspore-ai/mindinsight"
