# alb-acm-route53-ingress

## How to configure a Shared ALB within Humanitec

### Objectives
- Generate DNS names such as `${app}-${env}.apps.mycompany.dev`
- Use a public facing ALB
- Create a Shared ALB for use in multiple workloads

### Architecture

ALB Architecture with Humanitec]
![ALB Architecture with Humanitec](images/architecture.png)

DNS Architecture
![DNS Architecture](images/architecture-dns.png)

This example uses [ALB Controller `Group Names` feature](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/#group.name) to use an existing ALB to provide ingress for multiple namespaces and services, along with wildcard DNS and ACM to allow the creation of dynamic hostnames.

### Steps
  - Configure Humanitec Onboarding User
  - Configure an EKS cluster
  - Deploy ALB Controller [https://kubernetes-sigs.github.io/aws-load-balancer-controller/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) (v2.4 was tested)
    - Configure IAM Roles for Service Accounts (IRSA) 
    - Don't forget to tag your subnets properly

In your AWS account, with Terraform or similar:
  - Configure a Route 53 Hosted Zone
  - Configure a wildcard ACM certificate
In your EKS cluster:
  - Deploy a Shared ALB into a namespace
In your AWS account, with Terraform or similar:
  - Configure a wildcard CNAME to the ALB CNAME from the prior step (or use `external-dns` directly from within the EKS Cluster)

In Humanitec:
  - Configure a Resource Definition `EKS` in Humanitec
  - Configure a Resource Definition `Wildcard DNS` in Humanitec
  - Configure a Resource Definition `Ingress` in Humanitec
  - Add matching criteria for all the resources
  - Create an App, add a `shared DNS`, use the resource ID from the Wildcard DNS
  - Create a workload, add an image (ex: `httpd:latest`) add an ingress (select `shared dns`) - `Prefix: /, port 80`, configure the service ports `name: http, port: 80, container port: 80`

#### Configure a Route 53 Hosted Zone
- Using Terraform or any other tool, configure a Hosted Zone.

####  Configure a Wildcard ACM certificate
- Using Terraform or any other tool, configure and request a certificate, as an example, for domain name request use `*.apps.mycompany.dev` and `apps.mycompany.dev`
- Make sure to create the Route 53 validation records in Route 53

#### Deploy a Shared ALB into a namespace
- Deploy using kubectl or any other tool of your choice the following manifest [manifests/shared-alb-final.template.yaml](manifests/shared-alb-final.template.yaml)
  - This manifest will:
    - Create a blackhole service, optionally, you can create a deployment with a custom `404` or some sort of redirection
    - Create an ALB named `alb-public`
  - You must configure
    - Scheme: internal or public-facing
    - Subnets, if you did not tag them or added them to the controller
    - Configure a trusted default deployment `404` or `redirect` image (or use a blackhole service)
    - ACM Certificate ARN
    - ALB Group Name: used to combine ALBs [https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/#group.name](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/#group.name) 

#### Configure a wildcard CNAME to the ALB Hostname
- With the ALB Hostname, within Route 53, select your hosted zone and configure:
  - Wildcard CNAME `*.apps.mycompany.dev` -> `alb-XXX.ca-central-1.elb.amazonaws.com`
  - or setup external DNS in your cluster
    - You will need proper IRSA permissions within the service account that external DNS runs on [https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/integrations/external_dns/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/integrations/external_dns/)

#### Configure a Resource Definition `EKS` in Humanitec
- See [humanitec-terraform/eks.tf](humanitec-terraform/eks.tf)
Use this if you don't have an EKS cluster already configured

#### Configure a Resource Definition `Wildcard DNS` in Humanitec
- See [humanitec-terraform/wildcard-dns.tf](humanitec-terraform/wildcard-dns.tf)

#### Configure a Resource Definition `Ingress` in Humanitec
- See [humanitec-terraform/ingress.tf](humanitec-terraform/ingress.tf)
Do not forget to configure your scheme, subnets if needed, and any other service, you might need to add more variables to acomplish this.

#### Configure an Application in Humanitec
- See [humanitec-terraform/app.tf](humanitec-terraform/app.tf)


#####  Deploy to Humanitec using Terraform
- Modify `humanitec-terraform/terraform.tfvars.example`
```
cd humanitec-terraform/
terraform init -upgrade
terraform apply
```
- Make sure to always use `terraform init -upgrade` as we constantly upgrade the Terraform provider.

#### Deploy a Score app

This application will create a workload called `backend` along the dependencies for a shared dns `myalbdns` and a ingress `myalbingress` configured earlier.

See [score/score.yaml](score/score.yaml) and [score/extensions.yaml](score/extensions.yaml), and for more details [https://docs.score.dev/docs/reference/humanitec-extension/](https://docs.score.dev/docs/reference/humanitec-extension/) and [https://github.com/score-spec/score-humanitec](https://github.com/score-spec/score-humanitec).

```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export APP_NAME="myalbapp"

score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env development -f score/score.yaml --extensions score/extensions.yaml --deploy
```

Verify `myalbapp-development.apps.mycompany.dev` to see your application.

### TODO:
- Terraform examples for ACM/Route53
- External DNS integration
- Setup a mix of private/internal, shared and private ALBs