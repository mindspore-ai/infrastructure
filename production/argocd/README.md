# ArgoCD yaml
the raw yaml is fetched from https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install argocd
````$xslt
cd production/argocd
kubectl apply -f namespace.yaml
kubectl apply -f argocd_install.yaml -n argocd
````