#!/bin/bash

exim4_elb_id="asdf-exim4-elb"
exim4_elb_ip="192.168.0.1"
web_elb_id="asdf-web-elb"
web_elb_ip="185.6.89.1"
namespace="default"
web_domain="mailweb.openeuler.io"
admin_mail="freesky.edward@gmail.com"
admin_user="openeuler"
mail_domain="openeuler.io"

file_temp=./mailman-with-postgres.yaml

cp $file_temp temp.yaml
sed -i "s/<exim4-elb-id>/$exim4_elb_id/g" temp.yaml && \
sed -i "s/<exim4-elb-ip>/$exim4_elb_ip/g" temp.yaml && \
sed -i "s/<web-elb-id>/$web_elb_id/g" temp.yaml && \
sed -i "s/<web-elb-ip>/$web_elb_ip/g" temp.yaml && \
sed -i "s/<namespace>/$namespace/g" temp.yaml && \
sed -i "s/<admin-mail>/$admin_mail/g" temp.yaml && \
sed -i "s/<web-domain>/$web_domain/g" temp.yaml && \
sed -i "s/<admin-user>/$admin_user/g" temp.yaml && \
sed -i "s/<mail-domain>/$mail_domain/g" temp.yaml

mv temp.yaml mailman-deployment.yaml
