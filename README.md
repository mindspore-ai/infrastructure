# Infrastructure

This project contains all necessary dockerfile and yaml files that used provision the mindspore community:
```$xslt
├── development #contains all developing files (helm charts, init scripts, dockerfile)
└── production #contains the final yaml file that will be used in our production environment.   
```
All of the components are deployed via [ArgoCD](https://argoproj.github.io/argo-cd/), 
please visit: https://dev-deploy.mindspore.cn/login for more detail.

NOTE: The argocd will use the pod name as default admin password, in order to keep it simple, we patched
the password secret via command:
```$xslt
kubectl patch secret -n argocd argocd-secret  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" realpassword | tr -d ':\n')'"}}'
```

# Components

## Basic ArgoCD

## Basic Secrets Manager
secrets manager will sync specified secrets from vault server and it use `AppRole` to retrieve all secrets, therefore we
need create approle secret manually before deploying.
1. enable vault approle
```$xslt
vault auth enable approle
```
2. create policies for secrets manager
```$xslt
cat > mindspore-secrets-manager.hcl  <<EOF
path "secret/data/mindspore/*" {
  capabilities = ["read"]
}
EOF
cat mindspore-secrets-manager.hcl | vault policy write mindspore-secrets-manager -
```
3. create vault role
```$xslt
vault write auth/approle/role/mindspore-secret-manager policies=mindspore-secret-manager secret_id_num_uses=0 secret_id_ttl=0
```
4. get role id and secret id
```$xslt
vault read --field role_id auth/approle/role/mindspore-secrets-manager/role-id
vault write --field secret_id -force auth/approle/role/mindspore-secrets-manager/secret-id
```
5. create secret for secrets manager
```$xslt
kubectl create secret generic vault-approle-secret --from-literal role_id=<role-id> --from-literal secret_id=<secret-id>
```

## Basic Vault



## Mail System
It's based on the [Docker mailman](https://github.com/maxking/docker-mailman), but all components are upgraded into k8s version.
Visit: https://mailweb.mindspore.cn for more detail.

## Jenkins System
It's based on [Jenkins Helm chart](https://github.com/helm/charts/tree/master/stable/jenkins) within all slave nodes
are configured via StatefulSets and will register them self when starting up.
Visit http://build.mindspore.cn for more detail.

## Repo Serving System
It's a simple repo deployment that served with nginx, now it's only for developing purpose.
Visit https://dev-repo.mindspore.cn/repository for more detail.

## Official Website
It's mindspore's official website, please visit https://wwww.mindspore.cn

## CI Bot System
It's very similar to k8s' [prow](https://github.com/kubernetes/test-infra) system, but this component is designed to handle
gitee requests.

## Secrets Manage System
It's based on [secret manager helm chart](https://github.com/tuenti/secrets-manager) that holds and converts all Valut secrets.

