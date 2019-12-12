# Important

The yamls in this folder used to generate the production cluster, please be careful before you trying change any word.

All important files are store at: 
```
https://storage.huaweicloud.com/obs/?agencyId=867bf353519742aab5037d1ba0af1d4e&region=cn-north-1&locale=zh-cn#/obs/manage/mindspore-internal/object/list
```


## Jenkins System
1. **Persistentvolumeclaim**: `cce-efs-import-k3paa03e-auh7` is created on Huaweicloud manually. 

## Repo System
1. **Persistentvolumeclaim**: `cce-efs-import-k410ji5h-hinm` is created on Huaweicloud manually.

## Bot system

## Mail system
1. the **configmap**: `mail/dkim-config` is created manually via command:
```
curl -o mindspore.key <file_from_remote> 
kubectl create configmap dkim-config --from-file=mindspore.key --namespace mail
``` 

