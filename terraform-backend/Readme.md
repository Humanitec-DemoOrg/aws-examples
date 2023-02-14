# Custom Terraform State for Humanitec

## Background
The following example shows how to configure a custom Terraform S3 State. We recommend a different role for state management than 

### Steps
- Configure an IAM user as described in [https://github.com/nickhumanitec/humanitec-onboarding-aws-iam-user](https://github.com/nickhumanitec/humanitec-onboarding-aws-iam-user)
- Terraform Role:
    - Configure a role for Terraform to assume as described in [https://github.com/nickhumanitec/humanitec-onboarding-aws-iam-user](https://github.com/nickhumanitec/humanitec-onboarding-aws-iam-user)
- Terraform State: Create a S3 bucket, DynamoDB table, policy and role as described in [terraform/main.tf](terraform/main.tf)
    - The role is a cross-account like role that trusts the same account, and can be assumed if an user has a policy to assume roles with prefix `humanitec`.
    - Identity the S3, DynamoDB table and Role ARN
- In [main.tf](main.tf):
    - Configure the state values within the `script (override.tf)` section. This section defines dynamically the state key based on the Humanitec context, when the driver is called it is populated statically from the context, similar to other Terraform wrapper technologies. This section requires access keys, similar to how Terrform resource deployment needs them, these could be the same or different, depends on how you configure your roles.
    - Configure the role to be assumed within `variables`, this is the role that is used by Terraform to deploy resources.
