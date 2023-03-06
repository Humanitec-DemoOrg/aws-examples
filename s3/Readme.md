# S3

## Background
The following example shows how to configure a Terraform S3 Compatible driver within Humanitec with support for IAM roles.

```
terraform init -upgrade
terraform apply

export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export APP_NAME="test-s3-tf"
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env development -f score.yaml --deploy
```
