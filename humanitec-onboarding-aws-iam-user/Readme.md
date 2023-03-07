# AWS IAM User Onboarding

## Background
Humanitec follows the least privilege approach to security and access to customer's environments.
Humanitec uses an AWS IAM user per account with long term credentials to communicate with your AWS EKS clusters, and AWS IAM roles with temporary credentials to manage AWS Resources with Terraform.

### Policies
The Humanitec AWS IAM User requires the following permissions:
- AWS EKS Deployment access to clusters tagged with `Humanitec: true`.
- Allow Humanitec Terraform management cloud to assume roles in your target AWS accounts to manage your infrastructure, the rolename must start with the prefix `humanitec`.
- Access to the AWS API from Humanitec [outbound public IPs](https://docs.humanitec.com/getting-started/technical-requirements).

### How Humanitec uses the AWS credentials
- To deploy to your AWS EKS clusters:
    - Humanitec uses the AWS IAM User access key and secret to call the AWS EKS API, and get the metadata required to communicate to your AWS EKS cluster.
    - Humanitec deploys to your AWS EKS cluster over a secure tunnel.
- To deploy and manage infrastructure:
    - Humanitec uses the AWS IAM User access key and secret to call the AWS STS API, assumes the specified AWS IAM role within your Humanitec resource definition, and gets AWS temporary credentials.
    - Humanitec deploys to your AWS account over a secure tunnel.

### Credentials and Access Responsibility

![Roles and Access](images/humanitec-roles.png)

Humanitec's:
- Custody of AWS IAM long term credentials per account and resource definitions.
- AWS Role Assumption and management of temporary access credentials.
- Maintenance of the Humanitec AWS IAM user standard policies, and publication of reference manifests.

Customer's:
- Create and maintain the Humanitec AWS IAM user according to manifests provided by Humanitec.
- Rotate AWS IAM long term credentials and update them within Humanitec for each AWS EKS cluster, AWS account and Humanitec resource definition.
- Create and maintain AWS IAM roles within their AWS accounts to manage the infrastructure.
- Create and maintain AWS IAM policies allowing and denying access to actions based on their specific needs.

## How to allow Humanitec to access your AWS EKS Clusters
- For _each_ of your AWS Accounts:
    - Create the Humanitec AWS IAM User
    - Tag the clusters that Humanitec needs access to with `Humanitec:true`
    - For each AWS EKS cluster tagged, configure your AWS EKS Cluster config map
```
kubectl describe -n kube-system configmap/aws-auth
```

```
  mapUsers: |
    - "groups":
      - "system:masters"
      "userarn": "arn:aws:iam::ACCOUNT_ID:user/USERNAME"
      "username": "USERNAME"
```
- Within Humanitec: use the credentials to configure your AWS EKS resources with the following format:
```
    {
    "aws_access_key_id":"AKIAIOSFODNN7EXAMPLE",
    "aws_secret_access_key":"wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }
```

## How to allow Humanitec to access your AWS infrastructure via Terraform

![Humanitec Terraform Roles](images/humanitec-terraform-roles.png)

- Our examples use the  Humanitec Terraform Provider,  documentation can be found [here](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs).
- **Create IAM AWS** Roles with AWS IAM policies as needed, see [../s3/terraform/example-s3-admin-role/main.tf](../s3/terraform/example-s3-admin-role/main.tf) for a complete example.
    - Make sure your AWS IAM role name starts with the prefix `humanitec`, for example `humanitec-s3-admin-role`.
- Configure your Terraform to support AWS IAM roles, [see a complete example](../s3/terraform/bucket/main.tf).
```
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.assume_role_session_name
    external_id  = var.assume_role_external_id
  }
}
```
- Configure a Humanitec Resource Definition with the AWS IAM information, [see a complete example](../s3/main.tf).

```
resource "humanitec_resource_definition" "aws_terraform_resource_s3_bucket" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "aws-terrafom-s3-bucket"
  name        = "aws-terrafom-s3-bucket"
  type        = "s3"

  criteria = [
    {
      res_id = null
    }
  ]

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "s3/terraform/bucket/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region                   = var.region,
          bucket                   = "my-company-my-app-$${context.app.id}-$${context.env.id}",
          assume_role_arn          = "arn:aws:iam::ACCOUNT_ID:role/<<HUMANITEC-ROLE-NAME-FOR-S3>>"
          assume_role_session_name = "<<HUMANITEC-SAAS-ACCESS-EXAMPLE-TO-S3>>"
          assume_role_external_id  = "<<SOME-KNOWN-EXTERNAL-ID>>"
        }
      )
    }
  }

}
```

### Git Credentials
The example above goes to public Github, to configure a private git repository, you could adjust credentials like the example below:

```
  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key

      })
      source = jsonencode({
        ssh_key  = var.ssh_key # SSH Private Key (for connections over SSH). (Optional)
        password = var.password # Password or Personal Account Token. (Optional)
      })

    },
    values = {
      "source" = jsonencode(
        {
          path     = "iam-role-eks/terraform/parameter/"
          rev      = "refs/heads/main"
          url      = "https://github.com/MYPRIVATEORG/my-app-resources.git"
          username = var.username # User Name to authenticate. Default is `git`. 
        }
      )
      "variables" = jsonencode(
        {
          region                    = var.region
          terraform_assume_role_arn = var.terraform_role
        }
      )
    }
  }
  ```

### Humanitec native S3 and SQS driver
- The AWS IAM User policies in this repository do not allow the use of Humanitec native resource types such as AWS S3 and AWS SQS, they must be deployed with a custom Terraform driver. See a complete example [here](../s3).
