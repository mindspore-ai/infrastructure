.EXPORT_ALL_VARIABLES:
CHECK_SLAVE_TAG=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/ms_check_slave:0.0.2
REPO_TOOL_TAG=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/repo-tools:0.0.1

image_build:
	docker build -t ${CHECK_SLAVE_TAG} -f development/jenkins/dockerfile/slaves/mindspore_check/Dockerfile development/jenkins/dockerfile/slaves/mindspore_check
	docker build -t ${REPO_TOOL_TAG} -f development/repo/dockerfiles/Dockerfile development/repo/dockerfiles

image_push:
	docker push ${CHECK_SLAVE_TAG}
	docker push ${REPO_TOOL_TAG}

# Command used to update jenkins slave cluster
install_jenkin_slaves: image_build image_push
	kubectl apply -f production/jenkins/small-slaves.yaml
	kubectl apply -f production/jenkins/medium-slaves.yaml





