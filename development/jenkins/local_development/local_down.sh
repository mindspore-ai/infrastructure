#!/bin/bash

export CURRENT_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
if [[ "${CLUSTER_NAME}xxx" == "xxx" ]];then
    CLUSTER_NAME="development"
fi
export CLUSTER_CONTEXT="--name ${CLUSTER_NAME}"

# clean up
function cleanup {
  echo "Uninstall jenkins services"
  #kubectl delete -f ${CURRENT_ROOT}/code-server-development.yaml
  echo "Deleting nfs services"
  helm delete nfs-server
  echo "Running kind: [kind delete cluster ${CLUSTER_CONTEXT}]"
  kind delete cluster ${CLUSTER_CONTEXT}

}
export KUBECONFIG="$(kind get kubeconfig-path ${CLUSTER_CONTEXT})"

cleanup
