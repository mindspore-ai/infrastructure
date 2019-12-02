# Notice
This base yamls in this folder are initially based on
the [jenkins chart](https://github.com/helm/charts/tree/master/stable/jenkins) 
commit: 322baa4a944f63443f7fd83ac4838dc8ce756aa0

# Configuration
The whole configuration for jenkins cluster is located in `jenkins/values.yaml`, also there is a file name `hw_override.yaml` which used to override the partial default values,
we need ensure the options in `hw_override.yaml` are correct before we submit the
resources into kubernetes cluster.


# Command to generate the final yaml
```$xslt
helm template ./jenkins --namespace jenkins-system -f jenkins/values.yaml -f jenkins/hw_override.yaml --name openeuler
```

# Node Notes
jenkins slave's working dir will be put at the path of `/jenkins_agent_dir` therefore it's required to make the folder ready
before assign any pods into that nodes.