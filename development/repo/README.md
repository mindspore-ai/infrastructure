# Notice
This folder used to generate final yaml that can be used to setup the mindspore rpm repo service.
Please update the `values.yaml` at least with key and cert file before applying yaml.
```$xslt
  keyFile: "please update this with correct key file url"
  certFile: "please update this with correct cert file url"
  loadBalancerIP: "EIP for load balancer"
  elbID: "load balancer ID"
```

# Dockerfile
There are 3 images used for repo service and they are:
1. ``Dockerfile``: it's a repo tool image which used to setup up the nginx environment or update the repo
data via a kubernetes job resource.
2. ``Dockerfile.nginx_uwsgi_flask``: it's a simple RESTful application and will be deployed along with the main nginx
deployment, it will expose the 80 port and our CI/CD system can utlize that endpoint to trigger a repo update action.
3. ``Official nginx dockerfile``: it's used in the main deployment and will expose 443 port to our repo clients.

# Trigger a repo update
In order to update the repo, an POST request is needed with following parameters:
```$xslt
Endpoint: http://<repo-service-ip>:80/republish
Header:
Authorization: Basic <base64<username:password>>
Content-Type: application/json
Request Body:
{
    "projects": [
        {
            "localpath": "euleros/euler_v2_x86_64",
            "http_url": "http://117.78.1.88:82/euleros/Packages/"
        }
    ]
}
```
then a k8s job will be created to fetch all rpm files into repo data volume.

# TODO
Support fully clone a folder and subfolder in repo tool image, for instance
```$xslt
wget -N -r -np -nH -k -L -p -A '*' -R "index.html*" --tries=5  http://117.78.1.88:82/mindspore_euleros/
```

# Generate yaml Command
```$xslt
helm template repo-chart  -f repo-chart/values.yaml --namespace repo --name mindspore  > deployment.yaml
```
