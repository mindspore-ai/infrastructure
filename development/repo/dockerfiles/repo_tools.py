# -*- coding: UTF-8 -*-
import argparse
import datetime
import json
import base64
import os
import pytz
import sys
import subprocess

# Used to prepare the key&cert file used by nginx service
def prepare_repo(arg_instance):
    print("starting to prepare for nginx server")
    local_folder = "/etc/nginx/ssl/"
    if not os.path.isdir(local_folder):
        os.mkdir(local_folder)
    print("starting to download key file {0}".format(arg_instance.key_file))
    ret = subprocess.run(["curl -o {0} {1}".format(os.path.join(local_folder, "privkey.pem"), arg_instance.key_file)], shell=True)
    if ret.returncode != 0:
        print("failed to get key file for nginx service: {0}", ret.stdout)
    print("starting to download cert file {0}".format(arg_instance.cert_file))
    ret = subprocess.run(["curl -o {0} {1}".format(os.path.join(local_folder, "fullchain.pem"), arg_instance.cert_file)], shell=True)
    if ret.returncode != 0:
        print("failed to get cert file for nginx service: {0}", ret.stdout)

# The acceptable json content would be like:
# {
#    "projects": [
#        {
#            "localpath": "xxxx",
#            "http_url": ""
#       },
#        {
#            "localpath": "xxxx",
#            "http_url": ""
#        }
#    ]
# }
# 'update_repo' will download every rpm packages (overwrite if it exists) specified in 'http_url' root folder via wget tool and the rpm will be arranged in the format of
# .
# ├── packages
# |      └────── AAA.rpm
# |      └────── BBB.rpm
# |      └────── repodata
def update_repo(arg_instance, working_dir):
    content = base64.b64decode(arg_instance.repo_json.encode('utf-8')).decode('utf-8')
    repo = json.loads(content)
    if "projects" not in repo or repo["projects"] is None or not isinstance(repo["projects"], list):
        print("unacceptable json content when trying to update repo {0}".format(arg_instance.repo_json))
        sys.exit(1)
    for project in repo["projects"]:
        if "localpath" not in project or "http_url" not in project:
            print("project {0} format unacceptable, skipping".format(project))
            continue
        handle_single_repo_update(project, working_dir)        

def handle_single_repo_update(project, working_dir):
    #check and create the base repo folder
    base_repo_folder = os.path.join(working_dir, project["localpath"])
    if not os.path.isdir(base_repo_folder):
        os.makedirs(base_repo_folder)
    # download rpms
    package_folder= os.path.join(base_repo_folder, "packages")
    if not os.path.isdir(package_folder):
        os.mkdir(package_folder)
    print("starting to sync rpms from {0} into folder {1}".format(project['http_url'], project['localpath']))
    ret = subprocess.run(["cd {0} && wget -N -r -nd -np -k -L -p -A '*.rpm' --tries=5 {1}".format(package_folder, project['http_url'])], shell=True)                                     
    if ret.returncode != 0:
        print("failed to download rpms from http url {0}, stdout {1}".format(project["http_url"], ret.stdout))
        sys.exit(1)
    #create or update repo
    print("starting to sync repodata folder {0}".format(os.path.join(package_folder, 'repodata')))
    if os.path.isdir(os.path.join(package_folder, 'repodata')):
        ret = subprocess.run(["cd {0} && createrepo --update .".format(package_folder)], shell=True)
    else:
        ret = subprocess.run(["cd {0} && createrepo .".format(package_folder)], shell=True)
    if ret.returncode != 0:
        print("failed to update repo with command result: {0}".format(ret.stdout))
        sys.exit(1)
    #Add timestamp file
    subprocess.run(["echo {0} > {1}".format(datetime.datetime.now(pytz.timezone('Hongkong')), os.path.join(package_folder, 'release_time.txt'))], shell=True)

if __name__ == "__main__":    
    parser = argparse.ArgumentParser(description='repo action collection.')
    parser.add_argument('action', type=str, metavar='ACTION', help='specify the action to perform, now only "prepare" or "update" are supported')
    parser.add_argument('--key-file', type=str, nargs='?', help='key file used in nginx for tls')
    parser.add_argument('--cert-file', type=str, nargs='?', help='cert file used in nginx for tls')
    parser.add_argument('--repo-json', type=str, nargs='?', default="{}", help='repo data used to update the official repo(s)')
    args = parser.parse_args()
    print("starting to perform action via command: {0}".format(args))

    if str(args.action)  == "prepare":
        prepare_repo(args)
    elif str(args.action) == "update":
        working_dir = os.environ.get("WORKING_DIR", "")
        if working_dir == "":
            print("Must specify 'WORKING_DIR' when perform repo update action")
            sys.exit(1)
        update_repo(args, working_dir)
    else:
        print("unsupported actions {0}, please specify 'prepare' or 'update'.".format(args.action))
        sys.exit(1)    
    sys.exit(0)
