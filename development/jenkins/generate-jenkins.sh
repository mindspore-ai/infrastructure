#!/usr/bin/env bash

export CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function install-helm {
  echo "checking helm"
  if hash helm 2>/dev/null; then
    echo "found helm on local"
  else
    echo "Install helm via script"
    HELM_TEMP_DIR=`mktemp -d`
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > ${HELM_TEMP_DIR}/get_helm.sh
    #TODO: There are some issue with helm's latest version, remove '--version' when it get fixed.
    chmod 700 ${HELM_TEMP_DIR}/get_helm.sh && ${HELM_TEMP_DIR}/get_helm.sh   --version v2.13.0
  fi
}


install-helm

echo "generating jenkins yaml..."
helm template ${CURRENT_DIR}/jenkins -f ${CURRENT_DIR}/jenkins/values.yaml -f ${CURRENT_DIR}/jenkins/hw_override.yaml --name openeuler > jenkins.yaml
echo "jenkins yaml generated with filename 'jenkins.yaml'."


