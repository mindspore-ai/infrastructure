.EXPORT_ALL_VARIABLES:
#Image used for jenkins' small slave
CHECK_SLAVE_TAG=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/ms_check_slave:0.0.2
#Image used for mindspore repo utils
REPO_TOOL_TAG=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/repo-tools:0.0.3
#Image used for mindspore repo listener
REPO_UPDATE_LISTENER=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/repo-listener:0.0.2
#Image used for mindspore mail services
MAIL_WEB=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/mail-web:v1.0.0
MAIL_EXIM=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/mail-exim4:v0.1.0
MAIL_CORE=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/mail-core:v0.1.0
MAIL_GIT_UTIL=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/git-tools:0.0.1
MAIL_CORE_UTIL=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/mailman-core-utils:0.0.1
MAIL_DATABASE=swr.cn-north-1.myhuaweicloud.com/hwstaff_h00223369/postgres:9.6-alpine

jenkins_image_build:
	docker build -t ${CHECK_SLAVE_TAG} -f development/jenkins/dockerfile/slaves/mindspore_check/Dockerfile development/jenkins/dockerfile/slaves/mindspore_check

jenkins_image_push:
	docker push ${CHECK_SLAVE_TAG}

repo_image_build:
	docker build -t ${REPO_TOOL_TAG} -f development/repo/dockerfiles/Dockerfile development/repo/dockerfiles
	docker build -t ${REPO_UPDATE_LISTENER} -f development/repo/dockerfiles/Dockerfile.nginx_uswgi_flask development/repo/dockerfiles

repo_image_push:
	docker push ${REPO_TOOL_TAG}
	docker push ${REPO_UPDATE_LISTENER}

mail_image_build:
	#docker build -t ${MAIL_WEB} -f development/mail/dockerfile/web/Dockerfile development/mail/dockerfile/web/
	#docker build -t ${MAIL_EXIM} -f development/mail/dockerfile/exim4/Dockerfile development/mail/dockerfile/exim4/
	#docker build -t ${MAIL_CORE} -f development/mail/dockerfile/core/Dockerfile development/mail/dockerfile/core/
	docker build -t ${MAIL_GIT_UTIL} -f development/mail/dockerfile/core_utils/Dockerfile.git_tool development/mail/dockerfile/core_utils/
	docker build -t ${MAIL_CORE_UTIL} -f development/mail/dockerfile/core_utils/Dockerfile development/mail/dockerfile/core_utils/

mail_image_push:
	#docker push ${MAIL_WEB}
	#docker push ${MAIL_EXIM}
	#docker push ${MAIL_CORE}
	docker push ${MAIL_GIT_UTIL}
	docker push ${MAIL_CORE_UTIL}

# Command used to update jenkins slave cluster
install_jenkin_slaves: jenkins_image_build jenkins_image_push
	kubectl apply -f production/jenkins/small-slaves.yaml
	kubectl apply -f production/jenkins/medium-slaves.yaml


