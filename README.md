# Infrastructure

This project contains all necessary dockerfile and yaml files that used provision the mindspore community:
```$xslt
├── development #contains all developing files (helm charts, init scripts, dockerfile)
└── production #contains the final yaml file that will be used in our production environment.   
```
All of the components are deployed via [ArgoCDP](https://argoproj.github.io/argo-cd/), 
please visit: https://dev-deploy.mindspore.cn/login for more detail.

# Components

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

