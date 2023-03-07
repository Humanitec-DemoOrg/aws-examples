# Custom Terraform State for Humanitec

## Background
The following example shows how to configure a custom Terraform S3 State. We recommend a different role for state management than for resource management.

### Steps
- Configure an IAM user as described in [../humanitec-onboarding-aws-iam-user](../humanitec-onboarding-aws-iam-user)
- Terraform Role:
    - Configure a role for Terraform to assume as described in [../humanitec-onboarding-aws-iam-user](../humanitec-onboarding-aws-iam-user)
- Terraform State: Create a S3 bucket, DynamoDB table, policy and role as described in [terraform/main.tf](terraform/main.tf)
    - The role is a cross-account like role that trusts the same account, and can be assumed if an user has a policy to assume roles with prefix `humanitec`.
    - Identity the S3, DynamoDB table and Role ARN
- Within the Humanitec Driver Resource definition [main.tf](main.tf):
    - Configure the state values within the `script (override.tf)` section. This section defines dynamically the state key based on the Humanitec context, when the driver is called it is populated statically from the context, similar to other Terraform wrapper technologies. This section requires access keys, depending on how you configure your roles (under different IAM users), these might be different than the access keys used to manage resources.
    - Configure the role to be assumed within `variables`, this is the role that is used by Terraform to deploy resources.
