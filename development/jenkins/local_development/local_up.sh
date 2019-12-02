#!/bin/bash

export CURRENT_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export LOG_LEVEL=3
export CLEANUP_CLUSTER=${CLEANUP_CLUSTER:-0}

if [[ "${CLUSTER_NAME}xxx" == "xxx" ]];then
    CLUSTER_NAME="development"
fi

export CLUSTER_CONTEXT="--name ${CLUSTER_NAME}"

export KIND_OPT=${KIND_OPT:=" --config ${CURRENT_ROOT}/kind-config.yaml"}

# spin up cluster with kind command
function kind-up-cluster {
  check-prerequisites
  check-kind
  echo "Running kind: [kind create cluster ${CLUSTER_CONTEXT} ${KIND_OPT}]"
  kind create cluster ${CLUSTER_CONTEXT} ${KIND_OPT}
}

# install helm if not installed
function install-helm {
  echo "checking helm"
  which helm >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "Install helm via script"
    HELM_TEMP_DIR=`mktemp -d`
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > ${HELM_TEMP_DIR}/get_helm.sh
    #TODO: There are some issue with helm's latest version, remove '--version' when it get fixed.
    chmod 700 ${HELM_TEMP_DIR}/get_helm.sh && ${HELM_TEMP_DIR}/get_helm.sh   --version v2.13.0
  else
    echo -n "found helm, version: " && helm version
  fi
}

# check if kubectl installed
function check-prerequisites {
  echo "checking prerequisites"
  which kubectl >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "kubectl not installed, exiting."
    exit 1
  else
    echo -n "found kubectl, " && kubectl version --short --client
  fi
}

# check if kind installed
function check-kind {
  echo "checking kind"
  which kind >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "installing kind ."
    GO111MODULE="on" go get sigs.k8s.io/kind@v0.4.0
  else
    echo -n "found kind, version: " && kind version
  fi
}


function install-jenkins-cluster-service {
  echo "installing helm service"
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

  install-helm
  helm init --service-account tiller --kubeconfig ${KUBECONFIG} --wait


  echo "Install nfs common utils into kind nodes"
  NODES=$(kind get nodes --name ${CLUSTER_NAME})
  NODES_ARY=($NODES)
  for key in "${!NODES_ARY[@]}"
  do
   echo "starting to patch node ${NODES_ARY[$key]} and install nfs-common utils"
   docker exec -it ${NODES_ARY[$key]} bin/bash -c "apt update && apt install nfs-common -y"
  done

  echo "Install nfs provisioner"
  kubectl create clusterrolebinding default-cluster-rule --clusterrole=cluster-admin --serviceaccount=default:default
  helm repo add cloudposse-incubator https://charts.cloudposse.com/incubator
  helm install --name nfs-server cloudposse-incubator/nfs-provisioner --set persistence.storageClass=standard --set persistence.size=1Gi --wait

}

echo $* | grep -E -q "\-\-help|\-h"
if [[ $? -eq 0 ]]; then
  echo "Customize the kind-cluster name:

    export CLUSTER_NAME=<custom cluster name>  # default: integration

Customize kind options other than --name:

    export KIND_OPT=<kind options>
"
  exit 0
fi

kind-up-cluster

export KUBECONFIG="$(kind get kubeconfig-path ${CLUSTER_CONTEXT})"

install-jenkins-cluster-service
