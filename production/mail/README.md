# 邮件服务介绍:
邮件服务一共包含下面几个组件
## mailman-website
mailman-website提供邮件列表的管理和归档查看功能，管理员可以通过该界面管理邮件列表以及设置列表不同的行为。
## mailman-core
邮件列表的核心服务，涉及到邮件接收，转发，等核心功能都在改组件。
## exim4
邮件系统的MTA组件，主要跟mailman-core组件交互，比如将收到的邮件转给mailman-core服务，以及接收来自core的所有邮件转发请求, exim4需要调度到指定的机器上(该机器包含EIP)。
## mailman-utils
邮件系统的辅助组件，用来根据用户的配置，修改对应的邮件列表的回复模板(welcome,confirm)，具体可以参考(development/mail/templates/README.md)
## database
mailman-website对应的数据库，当前使用postgress。
# 部署邮件服务到其他集群(域名)
如果有需求，你需要手动进行下面的一系列调整，后面yaml会迁移到helm chart，便于动态生成，不过目前仍需要手动修改。我们假设你部署的域名是example.com,步骤如下:
## 基础准备:
### 存储
集群通过PersistentVolumeClaim用到了2个外置存储:
1. db-data-vol: 用来存放数据库文件的，你需要根据实际的业务规划和基础设施修形态修改PVC信息，比如storageClassName， 比如磁盘大小。  
2. config-vol:  用来mailman core 和 exim4 pod共享访问的，所以你需要的是一个Share 磁盘(比如华为云上的nfs， sfs等)， 根据实际情况修改storageClassName 和大小规格。
### 外部访问
集群中需要配置2个外部访问的Service，假设你使用的是华为云，你需要对应修改如下:
1. mailman-exim4-service: 用来暴露exim4服务的，你需要对应修改`kubernetes.io/elb.id`为对应的elb ID，`loadBalancerIP`为对应的EIP。
2. mailman-web-service: 用来暴露邮件归档和管理网站的，你需要对应修改`kubernetes.io/elb.id`为对应的elb ID，`loadBalancerIP`为对应的EIP。
### Secrets准备:
邮件服务用到了2个Secrets，目前集群中的Secrets是通过secrets-manager从vault服务里面同步过来创建的，但是你也可以手动创建他们，具体定义和说明如下:
#### mailman-secrets
该秘密包含的信息如下:
1. `hyperkitty_api_key`: mailman core 服务通过该API调用hyperkitty的API，该字段是字符串，你可以自行设置。
2. `mailman_core_password` 和 `mailman_core_user`: mailman utils调用mailman coreAPI的认证账号信息，可以自行配置。
3. `secret_key`： mailman website的 秘钥，字符串，自行配置。
4. `postgres_user` 和 `postgres_password`： 数据库连接的默认用户名和密码，用于第一次启动配置。
5. `mailman_admin_email`： website默认的管理员邮箱，第一次登陆的时候，通过该邮箱找回密码，再以管理员登陆。
6. `exim4_credential`: 用来发邮件时登陆用的，exim4现在的配置是需要登陆才能发邮件，执行以下命令生成(需要安装exim4组件):`/usr/share/doc/exim4-base/examples/exim-adduser`,生成的credential放在目录/etc/exim4/passwd文件中。
7. `exim4_credential_username`和`exim4_credential_password`: 就是上面生成credential时指定的用户名和密码。
8. `dkim_key`: 用来发送邮件时做签名的，他也是分公私钥的，这里配置的是私钥，公钥在下面配置DNS的时候会用到，生成的方式跟我们生成ssh 登陆的rsa key一致。
### mailman-cert-secrets
该秘钥包含的信息如下:
1. `server_crt`: 网站https用到的证书
2. `server_key`: 网站https用到的证书

### Yaml文件修改:
Yaml中包含了跟部署业务相关的配置，需要在迁移前手动修改:
#### ConfigMap: mailman-exim4-configmap
1. `domainlist mm3_domains=` 修改为实际的domain 比如 example.com
2. `DKIM_FILE`：修改为具体域名的key，比如example.key
3. `dc_other_hostnames`: 修改为实际的域名，比如 example.com
4. `dc_relay_nets`: 修改为实际的内网ip段，比如k8s集群的ip段是172.16.0.0/16，那就修改为`172.16.0.0/16`。
5. `ALLOWED_HOSTS`： 需要按照实际的域名信息修改，注意: 需要将website实际的EIP添加进数组。

#### Deployment: mailman-core-utils
1. `DEFAULT_DOMAIN_NAME`： 修改为实际的域名
2. `DEFAULT_MAIL_LISTS`： 修改为实际默认需要创建的邮件列表。
3. `TEMPLATE_REPO`: 修改为实际存放templates的github仓库。

#### StatefulSet： mailman-exim4
1. `nodeSelector`：里面包含的node标签就是你需要调度到的指定worker机器本身包含的标签，确保能调度到这台机器上。

#### StatefulSet：mailman-exim4
1. `volumeMounts：/etc/exim4/dkim/mindspore.key`，挂载路径需要修改为实际域名的路径比如: example.key
2. `command`: 初始化脚本中需要修改文件名/etc/exim4/dkim/mindspore.key 改为实际的域名。

#### deployment: mailman-web
1. `MAILMAN_ADMIN_USER`: 初始化管理员账号名，需要改为实际的管理员账号名，(后续需要放到secrets里面)
2. `SERVE_FROM_DOMAIN`： website服务的域名名称，跟dns配置的域名保持一致。

## 域名配置(example.com):
1. `mailweb.example.com.`: 配置邮件系统website访问IP， 类型A
2. `smtp.example.com.`： 配置exim4 pod所在worker节点的EIP， 类型A
3. `mail.example.com.`: 配置exim4 Service所在的EIP，类型A
4. `example.com`: 类型MX，指向`mail.example.com`
5. `example.com`: 类型TXT，配置内容: `"v=spf1 ip4:<使用smtp.example.com指向的IP> -all"`
6. `default._domainkey.mindspore.cn.`: 类型TXT，配置内容: `"v=DKIM1;k=rsa;p=<dkim公钥内容>"`
7. `_dmarc.mindspore.cn.`: 类型TXT，配置内容: `"v=DMARC1;p=none;sp=none;adkim=r;aspf=r;fo=1;rf=afrf;pct=100;ruf=mailto:tommylikehu@gmail.com;ri=86400"`: 邮箱更换为管理员邮箱即可。

配置完成后可以通过工具检查spf，dkim dmarc等配置是否正确:

1. SPF: https://www.dmarcanalyzer.com/spf/checker/
2. DKIM: https://www.dmarcanalyzer.com/dkim/dkim-check/
3. DMARC: https://www.dmarcanalyzer.com/dmarc/dmarc-record-check/