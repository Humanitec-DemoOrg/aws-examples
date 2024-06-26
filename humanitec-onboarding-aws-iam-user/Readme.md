# Amazon IAM User Onboarding
## Support for AWS Trust
### Recommended way to configure your AWS Access
See [trust](trust) and [trust](https://developer.humanitec.com/platform-orchestrator/security/cloud-accounts/#aws-role-assumption)

Cloudformation with policies:
- To access EKS. The cluster must have the tag `Humanitec: true` and an IAM access entry with an access policy of `AmazonEKSClusterAdminPolicy` [trust/humanitec-eks-access.yaml](trust/humanitec-eks-access.yaml)
- To manage AWS resources: [trust/humanitec-resource-access.yaml](trust/humanitec-resource-access.yaml)

These policies must be updated everytime that new IPs or permissions are required.

## Background
Humanitec follows the least privilege approach to security and access to customer's environments.
Humanitec uses an Amazon IAM roles with temporary credentials to communicate with your Amazon EKS clusters and to manageAWS Resources with Terraform.

### Policies
The Humanitec Amazon Role  r requires the following permissions:
- Amazon EKS Deployment access to clusters tagged with `Humanitec: true`.
- Access to the AWS API from Humanitec [outbound public IPs](https://docs.humanitec.com/getting-started/technical-requirements).

### How Humanitec uses the AWS credentials
- To deploy to your Amazon EKS clusters:
    - Humanitec uses the Amazon IAM role, and get the metadata required to communicate to your Amazon EKS cluster.
    - Humanitec deploys to your Amazon EKS cluster over a secure tunnel.
- To deploy and manage infrastructure:
    - Humanitec uses the Amazon IAM role to call the AWS STS API, assumes the specified Amazon IAM role within your Humanitec resource definition.
    - Humanitec deploys to your AWS account over a secure tunnel.

### Credentials and Access Responsibility

Humanitec's:
- Custody of Amazon IAM role that is trusted by your account.
- AWS Role Assumption and management of temporary access credentials.
- Maintenance of the Humanitec Amazon Role standard policies, and publication of reference manifests.

Customer's:
- Create and maintain the Humanitec Amazon Role and trust user according to manifests provided by Humanitec.
- Create and maintain Amazon IAM roles within their AWS accounts to manage the infrastructure.
- Create and maintain Amazon IAM policies allowing and denying access to actions based on their specific needs.

**Humanitec strongly recommends following [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html), in particular [Apply least-privilege permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#grant-least-privilege), avoiding the creation of users and/or roles with the [`arn:aws:iam::aws:policy/AdministratorAccess`](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_administrator) policy, or similar full privileged permissions.**
## How to allow Humanitec to access your Amazon EKS Clusters
- For _each_ of your AWS Accounts:
    - Create the Humanitec IAM Role
    - Tag the clusters that Humanitec needs access to with `Humanitec:true`
    - For each Amazon EKS cluster tagged, configure your Amazon EKS Cluster config map or access entries

If using `API_AND_CONFIG_MAP` or `API` and `Amazon EKS access policies` (Recommended):

```
aws eks associate-access-policy --cluster-name CLUSTER_NAME --principal-arn arn:aws:iam::ACCOUNT_ID:user/USERNAME \
  --access-scope type=cluster --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy
```
**Humanitec strongly recommends following [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html), in particular [Apply least-privilege permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#grant-least-privilege), avoiding the creation of users and/or roles with the [`AmazonEKSClusterAdminPolicy`](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonEKSClusterPolicy.html) policy, [cluster vs namespaced users](https://docs.aws.amazon.com/eks/latest/userguide/access-policies.html), or similar full privileged permissions.**

If using `API_AND_CONFIG_MAP` or `API` and `Kubernetes RBAC authorization`:

```
aws eks create-access-entry --cluster-name CLUSTER_NAME --principal-arn arn:aws:iam::ACCOUNT_ID:user/USERNAME \
  --type STANDARD --username USERNAME
aws eks update-access-entry --cluster-name CLUSTER_NAME --principal-arn arn:aws:iam::ACCOUNT_ID:user/USERNAME \
  --username USERNAME --kubernetes-groups "humanitec"
```

Deploy the following manifest:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: humanitec-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: humanitec
```
**Humanitec strongly recommends following [Security best practices for RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/), in particular [Apply least-privilege permissions](https://kubernetes.io/docs/concepts/security/rbac-good-practices/), avoiding the creation of users and/or roles with the full privileged permissions.**


If using `CONFIG_MAP`
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
### Configure your EKS cluster resource definition credentials
Within Humanitec: use the credentials to configure your Amazon EKS resources with the following format:
```
    {
    "aws_access_key_id":"AKIAIOSFODNN7EXAMPLE",
    "aws_secret_access_key":"wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }
```

## How to allow Humanitec to access your AWS infrastructure via Terraform

- Our examples use the  Humanitec Terraform Provider,  documentation can be found [here](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs).
- **Create IAM AWS Roles with Amazon IAM policies as needed**, see [../s3/terraform/example-s3-admin-role/main.tf](../s3/terraform/example-s3-admin-role/main.tf) for a complete example.
    - Make sure your Amazon IAM role name starts with the prefix `humanitec`, for example `humanitec-s3-admin-role`.
- Configure your Terraform to support Amazon IAM roles, [see a complete example](../s3/terraform/bucket/main.tf).
- **_Humanitec does not provide examples on how to configure your Amazon IAM Policies, please contact your CIO/DevSecOps team or your nearest AWS Professional or AWS Partner for assistance_**
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
- Configure a Humanitec Resource Definition with the Amazon IAM information, [see a complete example](../s3/main.tf).

```
resource "humanitec_resource_definition" "aws_terraform_resource_s3_bucket" {
  driver_type = "humanitec/terraform"
  id          = "aws-terrafom-s3-bucket"
  name        = "aws-terrafom-s3-bucket"
  type        = "s3"

  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        access_key = var.access_key
        secret_key = var.secret_key
      }
    }),
    values_string = jsonencode({
      "source" =
        {
          path = "s3/terraform/bucket/"
          rev  = "refs/heads/main"
          url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
        }

      "variables" =
        {
          region                   = var.region,
          bucket                   = "my-company-my-app-$${context.app.id}-$${context.env.id}",
          assume_role_arn          = "arn:aws:iam::ACCOUNT_ID:role/<<HUMANITEC-ROLE-NAME-FOR-S3>>"
          assume_role_session_name = "<<HUMANITEC-SAAS-ACCESS-EXAMPLE-TO-S3>>"
          assume_role_external_id  = "<<SOME-KNOWN-EXTERNAL-ID>>"
        }

    })
  }

}
```

### Git Credentials
The example above goes to public Github, to configure a private git repository, you could adjust credentials like the example below:

```
  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        access_key = var.access_key
        secret_key = var.secret_key

      }
      source = {
        ssh_key  = var.ssh_key # SSH Private Key (for connections over SSH). (Optional)
        password = var.password # Password or Personal Account Token. (Optional)
      }

    }),
    values_string = jsonencode({
      "source" = 
        {
          path     = "iam-role-eks/terraform/parameter/"
          rev      = "refs/heads/main"
          url      = "https://github.com/MYPRIVATEORG/my-app-resources.git"
          username = var.username # User Name to authenticate. Default is `git`. 
        }
      
      "variables" =
        {
          region                    = var.region
          terraform_assume_role_arn = var.terraform_role
        }
    })
  }
  ```

### Humanitec native S3 and SQS driver
- The Amazon IAM User policies in this repository do not allow the use of Humanitec native resource types such as AWS S3 and AWS SQS, they must be deployed with a custom Terraform driver. See a complete example [here](../s3).
