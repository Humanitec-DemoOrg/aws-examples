# imagepullsecrets-howto

To configure private registries https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

- Identify your ECR URL: `667740703053.dkr.ecr.ca-central-1.amazonaws.com`
- Configure an IAM user with a policy to access to the repository
- Configure your registry, and allow credentails to be availanle to the CI.
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
