# custom-drivers-inputs-with-base-env

This repository shows how to configure `base-env`, to customize inputs for Humanitec Resource Definitions.

This allows us to create generic Humanitec Resource Definitions, still allowing to provide values for provisioning and runtime customization.

In this example, the resource definitions are for the Terraform Driver, but it does not deploy anything to your AWS accounts, it's an echo example. You must customize them appropriately, with roles and actual resources.

Note: A Humanitec Resource Definition is a logical construct that contains information on how to provision actual resources (AWS S3 buckets, DNS settings, etc). When an application requests a specific end resource (say an S3 bucket), the Resource Definition (for an S3 bucket) is then matched, and with the information provided within it, an actual S3 resource is then provisioned within the Cloud Provider.

**You are responsible for the Terraform State, either Terraform Cloud, S3, or similar location.**

Requeriments:
- Configure 2 environment types "development" and "production" [https://app.humanitec.io/orgs/$HUMANITEC_ORGANIZATION/org-settings/environment-types](https://docs.humanitec.com/guides/orchestrate-infrastructure/manage-environment-types).
- Configure all your `terraform.tfvars` with the `terraform.tfvars.example` and backend configuration for your Terraform.
- Deploy resources, deploy app with Score.
- From the UI, create a new environment (within the App Details Screen), to target production. Or see a GitHub end-to-end Dev to Prod pipeline example [https://github.com/nickhumanitec/humanitec-pipeline-example](https://github.com/nickhumanitec/humanitec-pipeline-example) for how to configure them automatically.

```
.
├── Readme.md
├── app-def
│   ├── app-specific-res-def                //Create a custom base-env, with custom parameters for each environment type
│   │   ├── base-env.tf
│   │   ├── dev-config
│   │   │   ├── terraform.tfstate           //State for dev config.
│   │   │   └── terraform.tfvars.example    //Dev env specific config
│   │   ├── prod-config
│   │   │   ├── terraform.tfstate           //State for prod config.
│   │   │   └── terraform.tfvars.example    //Prod env specific config
│   │   └── provider.tf
│   ├── app.tf
│   ├── provider.tf
│   ├── score.yaml                          //Score Application
│   ├── terraform.tfstate                   //State for the app
│   └── terraform.tfvars.example
└── generic-res-def                         //Generic S3 and RDS resources. Criteria for these can be `*`, in this example they are specific for an app.
    ├── provider.tf
    ├── rds.tf
    ├── s3.tf
    ├── terraform.tfstate                   // State for resource definitions.
    ├── terraform.tfvars.example
    └── variables.tf
```

Deployment

```
# Deploy generic resources. Verify the `drivers inputs`, they have a reference to a `base-env` (platform engineer's responsibility to define and customize)
cd generic-res-def/
terraform init && terraform apply
cd..

# Deploy base application (platform engineer's responsibility to define and customize)
cd app-def/
terraform init && terraform apply

# Deploy custom `base-env` per environment (platform engineer's responsibility to define and customize)
cd app-specific-res-def/

terraform init -backend-config="path=./dev-config/terraform.tfstate" -reconfigure
terraform apply -var-file="./dev-config/terraform.tfvars"

terraform init -backend-config="path=./prod-config/terraform.tfstate" -reconfigure
terraform apply -var-file="./prod-config/terraform.tfvars"

cd ..

# Deploy app with score (developer's responsibility)
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app custom-app --env development -f score.yaml --deploy 

```
