# humanitec-aws-examples

In this repository you will find a collection of examples on how to integrate your Humanitec within your Amazon environment.

- Allow Humanitec to access your Amazon EKS clusters and to perform Terraform deployments [humanitec-onboarding-aws-iam-user](humanitec-onboarding-aws-iam-user)
- How to configure Amazon ALB, ACM and Route 53 [alb-acm-route53-ingress](alb-acm-route53-ingress)
- How to configure Amazon EKS IRSA (Amazon EKS IAM roles for Service Accounts) for your workloads [iam-role-eks](iam-role-eks)
- How to configure a S3 Resource Definition with IAM roles to deploy with Terrafrom from Humanitec [s3](s3)
- How to configure your own Terraform Backend, and use it from within Humanitec [terraform-backend](terraform-backend)
- Example of Humanitec-Terraform Compatible Resource definitions for training [terraform-training](terraform-training)
- GitHub end-to-end Dev to Prod pipeline example [https://github.com/nickhumanitec/humanitec-pipeline-example](https://github.com/nickhumanitec/humanitec-pipeline-example)
- Firewall Access: How Humanitec can access your infrastructure, how your infrastructure can communicate with Humanitec [humanitec-firewall-access](humanitec-firewall-access)
- Customize drivers inputs with a `base-env` [custom-drivers-inputs-with-base-env](custom-drivers-inputs-with-base-env)
- Service Account example [service-account](service-account)
- General Scripts to interact with the Humanitec API [scripts](scripts)
- RBAC Configurations: CI/CD Service Account and dynamic namespace roleBindings [rbac-howto](rbac-howto)
- Score Howto: Examples of the most common patterns to deploy with score [score-howto](score-howto)
- Operator Howto: Common configuration questions [operator-howto](operator-howto)
- Pull an Image from a Private Registry: [imagepullsecrets-howto](imagepullsecrets-howto)
