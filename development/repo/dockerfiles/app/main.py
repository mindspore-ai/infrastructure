import subprocess
import os
import sys
import json
import base64
import os.path
import datetime
from flask import Flask
from flask import request
from flask_basicauth import BasicAuth


# Validate the required job yaml file

JOB_YAML = "/etc/repo-update/update-repo-job.yaml"
if not os.path.isfile(JOB_YAML):
    print("job yaml file not exist, exiting...")
    sys.exit(1)

app = Flask(__name__)
app.config['BASIC_AUTH_USERNAME'] = os.environ.get('BASIC_AUTH_USERNAME')
app.config['BASIC_AUTH_PASSWORD'] = os.environ.get('BASIC_AUTH_PASSWORD')
basic_auth = BasicAuth(app)


@app.route('/republish', methods=['POST'])
@basic_auth.required
def republish():
    if request.json is None or not "projects" in request.json or request.json["projects"] is None:
        return "invalid request body, please specify the projects to republish", 400
    if not isinstance(request.json["projects"], list) or len(request.json["projects"]) == 0:
        return "invalid request body, please specify the projects via array", 400
    print("[{0}]: starting to republish repo with projects {1}".format(datetime.datetime.now(), request.json))
    exist = subprocess.run(["kubectl get job/update-repo-job -n {0}".format(os.environ.get('K8S_NAMESPACE'))], shell=True)
    if exist.returncode == 0:
        #This would be a little arbitary, but we delete it if it's existed for simple logic
        subprocess.run(["kubectl delete job/update-repo-job -n {0} --wait".format(os.environ.get('K8S_NAMESPACE'))], shell=True)
    # NOTE: update yaml and then apply
    content = base64.b64encode(json.dumps(request.json).encode('utf-8')).decode('utf-8')
    print("start to create update job with content {0}".format(content))
    result = subprocess.run(["cat {0} | sed -e \"s/PROJECT_VARIABLE/{1}/g\" | kubectl apply -f -".format(JOB_YAML, content)], shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    if result.returncode == 0:
        return "successfully triggered", 200
    else:
        return "failed to trigger update job error: \n {0}".format(result.stdout), 400

@app.route('/', methods=['GET'])
def index():
    return "http is not enabled for repo service, please use https instead", 200


if __name__ == '__main__':
    app.run()