.EXPORT_ALL_VARIABLES:
CHECK_SLAVE_TAG=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/ms_check_slave:0.0.2

slave_image_build:
	docker build -t ${CHECK_SLAVE_TAG} -f development/jenkins/dockerfile/slaves/mindspore_check/Dockerfile development/jenkins/dockerfile/slaves/mindspore_check

# Command used to update jenkins slave cluster
install_jenkin_slaves: slave_image_build
	kubectl apply -f production/jenkins/small-slaves.yaml
	kubectl apply -f production/jenkins/medium-slaves.yaml
