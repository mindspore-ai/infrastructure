#!/usr/bin/env bash

export CURRENT_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export KUBECONFIG="$(kind get kubeconfig-path --name="development")"
helm template ${CURRENT_ROOT}/../jenkins -f ${CURRENT_ROOT}/../jenkins/values.yaml -f ${CURRENT_ROOT}/../jenkins/local_override.yaml --name mindspore | kubectl apply -f -
