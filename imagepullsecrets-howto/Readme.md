# imagepullsecrets-howto

To configure private registries https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

- Identify your ECR URL: `667740703053.dkr.ecr.ca-central-1.amazonaws.com`
- Configure an IAM user with a policy to access to the repository, create Access keys: an access key ID (for example, AKIAIOSFODNN7EXAMPLE) and a secret access key (for example, wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY).
- Configure your registry, and allow credentails to be available to the CI
![Registries](images/registries.png)
- On deployment, when the Orchestrator detects an image from this repository, the secret will be injected automatically
```
---
...
      containers:
...
      imagePullSecrets:
          - name: regcred-667740703053
```

```
kubectl get secret -n <namespace>  | grep regcred
regcred-667740703053 
                                                    kubernetes.io/dockerconfigjson   1      41m
kubectl describe secret regcred-667740703053 -n <namespace>
Name:         regcred-667740703053
Namespace:    79454520-3b37-4e20-94c6-7def369f3488
Labels:       app.humanitec.io/expires=20230512T065151Z
              app.humanitec.io/full-environment-id=nick.testdev1.development
              app.humanitec.io/registry=667740703053
Annotations:  <none>

Type:  kubernetes.io/dockerconfigjson

Data
====
.dockerconfigjson:  4396 bytes
```
- Using the API https://api-docs.humanitec.com/#tag/Registry/paths/~1orgs~1%7BorgId%7D~1registries/post
```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
curl "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/registries" \
  -X POST -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
  --data '{"id":"myecrregistry","registry":"667740703051.dkr.ecr.ca-central-1.amazonaws.com","type":"amazon_ecr","enable_ci":true,"creds":{"username":"AKIAIOSFODNN7EXAMPLE","password":"wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"}}'
```
