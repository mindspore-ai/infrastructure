#!/bin/bash

set -xe

MASTER_URL=$1
MASTER_USERNAME=$2
MASTER_PASSWORD=$3
NODE_NAME=$4
NUM_EXECUTORS=$5
WORKING_DIR=$6
NODE_LABELS=$7
SHARE_FOLDER=$8

# Download CLI jar from the master
curl ${MASTER_URL}/jnlpJars/jenkins-cli.jar -o ~/jenkins-cli.jar

# Delete the node always
set +e
java -jar ~/jenkins-cli.jar -auth "${MASTER_USERNAME}:${MASTER_PASSWORD}" -s "${MASTER_URL}" delete-node ${NODE_NAME}
set -e

# Create node according to parameters passed in
cat <<EOF | java -jar ~/jenkins-cli.jar -auth "${MASTER_USERNAME}:${MASTER_PASSWORD}" -s "${MASTER_URL}" create-node "${NODE_NAME}" |true
<slave>
  <name>${NODE_NAME}</name>
  <description></description>
  <remoteFS>${WORKING_DIR}</remoteFS>
  <numExecutors>${NUM_EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy\$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
  </launcher>
  <label>${NODE_LABELS}</label>
  <nodeProperties/>
  <userId>${MASTER_USERNAME}</userId>
</slave>
EOF

# Save secret into dest folder
curl -X GET "${MASTER_URL}/computer/${NODE_NAME}/slave-agent.jnlp" -u "${MASTER_USERNAME}:${MASTER_PASSWORD}" | xmlstarlet sel -t -v "/jnlp/application-desc/argument[1]" > ${SHARE_FOLDER}/node_secret.id