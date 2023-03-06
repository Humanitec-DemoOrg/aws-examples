# S3

## Background
The following example shows how to configure a Terraform S3 Compatible driver within Humanitec with support for IAM roles.

### Create a Role
```
cd terraform/example-s3-admin-role
terraform init -upgrade
terraform apply
```

### Deploy Resource Definition
```
terraform init -upgrade
terraform apply
```

### Deploy Score App
```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export APP_NAME="test-s3-tf"
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env development -f score.yaml --deploy
```
