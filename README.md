# Infrastructure

This project contains all necessary dockerfile and yaml files that used provision the mindspore community:
```$xslt
├── development #contains all developing files (helm charts, init scripts, dockerfile)
└── production #contains the final yaml file that will be used in our production environment.   
```


# Components

## BASIC: ArgoCD Server
All of the components are deployed via [ArgoCD](https://argoproj.github.io/argo-cd/), 

**Website**: https://dev-deploy.mindspore.cn.

**NOTE**: The ArgoCD will use the pod name as default admin password, in order to keep the consistency, we patched
the password via command:

```$xslt
kubectl patch secret -n argocd argocd-secret  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" realpassword | tr -d ':\n')'"}}'
```

## BASIC: Vault Server
Vault server used to hold all sensitive secrets that used in the infrastructure. In order to enable tls support, the
certificate secrets ``vault-secret`` is required.
```$xslt
kubectl create secret generic vault-secret --from-file=./server.key  --from-file=./server.crt -n vault
```

**Website**: http://dev-secrets.mindspore.cn.

## BASIC: Secrets Manager
It's based on [secret manager](https://github.com/tuenti/secrets-manager) that holds and converts all vault secrets.
Secrets manager will sync specified secrets from vault server to k8s secret resource according to the CRD resource,
it use `AppRole` to retrieve all secrets, therefore we need create appropriate approle on vault manually before deploying.
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


## Mail System
It's based on the [Docker mailman](https://github.com/maxking/docker-mailman), but all components are upgraded into k8s version.

**Website**: https://mailweb.mindspore.cn.

## Jenkins System
It's based on [Jenkins Helm chart](https://github.com/helm/charts/tree/master/stable/jenkins) within all slave nodes
are configured via StatefulSets and will register them self when starting up.

**Website**: http://build.mindspore.cn for more detail.

## Repo Serving System
It's a simple repo deployment that served with nginx, now it's only for developing purpose.

**Website**: https://dev-repo.mindspore.cn/repository for more detail.

## Official Website
It's mindspore's official website, please visit https://wwww.mindspore.cn

## CI Bot System
It's based on kubernetess' [prow](https://github.com/kubernetes/test-infra) system, but some features are trimmed.

# Clusters
Now all mindspore components are deployed into two HuaweiCloud k8s clusters[CCE]. They are:

1. CCE on cn-north-1 which are all x86 based nodes

2. CCE ib cn-north-4 which are all arm based nodes
