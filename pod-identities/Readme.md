# pod-identities

The following example shows how to configure multiple workloads and their corresponding AWS IAM Roles using EKS Pod Identities. 

If you wish to utilize IAM roles for service accounts (IRSA), this repository might help you, however AWS recommends using the new EKS Pod Identities approach.

For more information about the EKS Pod Identities see the [AWS documentation](https://aws.amazon.com/blogs/aws/amazon-eks-pod-identity-simplifies-iam-permissions-for-applications-on-amazon-eks-clusters/)

Requirements:
* AWS Credentials with support to create IAM Roles and policies. For more information see the [AWS IAM Humanitec Onboarding User](../humanitec-onboarding-aws-iam-user)
* EKS Cluster
    * Kubernetes >=1.24
    * Cluster Access Configuration set to `API` or `API_AND_CONFIG_MAP`
    * `eks-pod-identity-agent` addon

## Target Architecture
![Humanitec EKS SVG](architecture.svg)

## Humanitec IAC
* Humanitec will [require a standard namespace](resource-definition/namespace.tf). This namespace is where all your workloads will be deployed.
* AWS IAM Policies:

    * In this example, we have defined 3 policies, two for [S3](resource-definition/policy-s3.tf), [S3ro](resource-definition/policy-s3ro.tf) and another for [SQS](resource-definition/policy-sqs.tf). These policies will be used for all your workloads, providing the same set of permissions agaisnt AWS resources, however, each workload will have access to only the resources that belong to its configuration as defined by the `Target Architecture`. These policies point to an inline Terraform manifest that actually creates the resources in AWS.
    * Each policy is identified by its parent caller resource by its class [`s3`](resource-definition/policy-s3.tf#L36),[`s3ro`](resource-definition/policy-s3ro.tf#L36) or [`sqs`](resource-definition/policy-sqs.tf#L36), this would allow to create different policies, such as `s3rw` for read and write operations, or `s3ro` for read-only. This is based on your applications needs. Humanitec does not provide AWS IAM Policy recommendations nor guidance, please contact your AWS Partner or AWS Architect to develop such policies.
* AWS Resources:

    * For the AWS resource that will require a policy, [S3](resource-definition/s3.tf#L8), [S3ro](resource-definition/s3ro.tf#L8) and [SQS](resource-definition/sqs.tf#L8) within their resource definition configuration, you will see a [co-provision of resources](https://developer.humanitec.com/platform-orchestrator/resources/resource-graph/#co-provision-resources) `provision` stanza.
    * Example of `provision` stanza.
        ```
        provision = {
            "aws-policy.s3" = {
            "is_dependent" : true,
            "match_dependents" : true
            }
        }
        ```
      Within this stanza, you can configure which policy will be created automatically. In the case depicted, the Orchestrator will create a policy with a class `s3`. If you had different kind of S3 policies, you would configure such `"aws-policy.s3rw"` or `"aws-policy.s3ro"`. This would also require to create two different classes of S3 resource definitions.
* AWS Resources and their AWS IAM Policies:

    * Each policy will receive a set of ARNs using the [Resource Selector Syntax](https://developer.humanitec.com/platform-orchestrator/resources/resource-graph/#resource-selectors) placeholder:

    * Example: `"$${resources['aws-policy.s3>s3'].outputs.arn}"`, this placeholder can be read as: retrieve all the ARNs of S3 buckets `>s3` that are requesting a policy of class s3 `aws-policy.s3`
    * If you had custom policies, you would need to adjust the class such as `"$${resources['aws-policy.s3rw>s3'].outputs.arn}"` or `"$${resources['aws-policy.s3ro>s3'].outputs.arn}"`. You would then need to [process and adjust them](resource-definition/source/s3-policy.tf#L34) as needed to build your policies.
    * Examples of a custom policy would be [`policy s3ro`](resource-definition/policy-s3ro.tf#L18), and its parent AWS Resource [`s3ro`](resource-definition/s3ro.tf#L8). Please note their class names and the way they are constructed, and how both resources are connected using the class `s3ro`.
* Deploying Applications with Score
    * Please see [backend.yaml](backend.yaml) and [frontend.yaml](frontend.yaml) for an example of how to request a specific resource with their policy, in particular the resources property.
        ```
        resources:
        "s3":
            type: s3
            class: mys3
        "s3ro":
            type: s3
            class: mys3ro
        "sqs":
            type: sqs
            class: mysqs
        ```
* AWS IAM Role:
    * In order to put everything together, it is important to define a a resource definition of type [`aws-role`](resource-definition/role.tf) along with a [workload and service account](resource-definition/workload-backend.tf). The role as a placeholder `$${resources.workload>aws-policy.outputs.arn}` which can be read as: For the current workload, find all the policies created, and retrieve their ARNs. This role then will be created in AWS, and an EKS Pod Identity association would be created using its [Terraform definition](resource-definition/source/role.tf).

