# score-howto

## Install Score
Please follow the instructions here [https://docs.score.dev/docs/get-started/install/](https://docs.score.dev/docs/get-started/install/)

## Use Cases
1. Simple workload: Image, custom command, args and environment variables: [score/basic.yaml](score/basic.yaml)
1. Attach a local Humanitec resource, and make it available to the environment: [score/resource.yaml](score/resource.yaml)
1. Configure resource limits such as CPU and memory: [score/limits.yaml](score/limits.yaml)
1. Configure annotations and labels: [score/basic.yaml](score/basic.yaml) and [score/extension-label-annotation.yaml](score/extension-label-annotation.yaml)
1. Configure a cronjob: [score/basic.yaml](score/basic.yaml) and [score/extension-cronjob.yaml](score/extension-cronjob.yaml)
1. Configure ingress and services: [score/nginx.yaml](score/nginx.yaml) and [score/extension-ingress.yaml](score/extension-ingress.yaml)
1. Configure volumes: [score/volumes.yaml](score/volumes.yaml)
1. Configure replicas: [score/extension-replicas.yaml](score/extension-replicas.yaml)
1. Empty dir: [score/emptydir.yaml](score/emptydir.yaml]) and [score/emptydir-extension.yaml](score/emptydir-extension.yaml)

### Deployment
```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export APP_NAME="app"
export APP_ENV="development"
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env $APP_ENV -f score.yaml --deploy
#or, if an extension is needed
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env $APP_ENV -f score.yaml --extensions extension.yaml --deploy
```
