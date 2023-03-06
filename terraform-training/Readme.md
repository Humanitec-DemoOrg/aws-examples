# terraform-training

```
terraform init -upgrade
terraform apply

export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export APP_NAME="myterraformapp"

score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env development -f score.yaml --deploy
```
