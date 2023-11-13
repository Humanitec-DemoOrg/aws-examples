# db-secrets-manager

The following example will allow you to:

- Create a new database in an existing RDS instance/cluster
- Connect to your existing RDS instance/cluster with secrets stored in AWS Secrets Manager
- Create a new username and password, and store it in AWS Secrets Manager

## How to deploy the example
- Configure `existing/resource-definition/terraform/resource-definition/terraform.tfvars.EXAMPLE` with your Humanitec organization, tokens and AWS Credentials
- Configure your existing RDS instance/cluster to be publicly accessible from the Humanitec IPs https://developer.humanitec.com/platform-orchestrator/security/overview/
  - if your database is not publicly accessibly, you will need to run a proxy (HAProxy) or similar to expose it to Humanitec IPs. The Humanitec driver over ssh does not support this example configuration
- Configure an AWS Secrets Manager Secret with the following information:
    - Create a file `mycreds.json`
    ```
      {
        "endpoint":"instancename.random-string.ca-central-1.rds.amazonaws.com",
        "password":"...",
        "username":"postgres",
        "database":"postgres"
      }
    ```
    - Create a secret `aws secretsmanager create-secret --name /db/myrds --secret-string file://mycreds.json`
    - Adjust your AWS crdentials/profile accordingly
    - Adjust `existing/resource-definition/terraform/resource-definition/db.tf` the input `postgres_master_secret` from `/db/myrds` to the location of your new secret
- `tofu init && tofu apply`
- Deploy with Score `score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app db-test-existing --env development -f existing/score.yaml --deploy`
- Verify the information is being displayed in your container
- Verify your database `psql -W -h instancename.random-string.ca-central-1.rds.amazonaws.com -p 5432 -U postgres -c "\du"`

## Creating a new RDS instance/cluster (instead of using an existing one)
Please follow https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest for more information. Replace the code under `exisitng/terraform` between lines 11 to 31, build your cluster with then `manage_master_user_password` option to automatically create the master password in AWS Secrets Manager. Everything else can be left as is.

## Multiple databases with multiples workloads within the same app
Adjust the database name/user inputs in your resource definition with the addition `$${context.res.id}` which produces a string similar to `modules.<workload name>.externals.<resource name>` or `shared.<resource name>`, this string needs to be cleaned up before you can use it within your scripts, split it accordingly and compute your new strings as needed in your Terraform.
```
new_db_name            = "$${context.app.id}-$${context.env.id}"
new_db_user            = "$${context.app.id}-$${context.env.id}"
new_db_secret          = "/db/$${context.app.id}/$${context.env.id}"
```
