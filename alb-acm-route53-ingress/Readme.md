# alb-acm-route53-ingress

## How to configure a Shared ALB within Humanitec

### Objectives
- Generate DNS names such as `${app}-${env}.apps.mycompany.dev`
- Use a public facing ALB
- Create a Shared ALB for use in multiple workloads

### Architecture
![ALB Architecture with Humanitec](images/architecture.png)

This example uses [ALB Controller `Group Names` feature](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/#group.name) to use an existing ALB to provide ingress for multiple namespaces and services, along with wildcard DNS and ACM to allow the creation of dynamic hostnames.

### Steps
Steps:
  - Configure Humanitec Onboarding User
  - Configure an EKS cluster
  - Deploy ALB Controller [https://kubernetes-sigs.github.io/aws-load-balancer-controller/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) (v2.4 is tested)
    - Configure IAM Roles for Service Accounts (IRSA) 

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
  - Create an App, add a `shared` DNS, use the resource ID from the Wildcard DNS
  - Add a ingress to a workload

#### Configure a Route 53 Hosted Zone
- Using Terraform or any other tool, configure a Hosted Zone.

####  Configure a Wildcard ACM certificate
- Using Terraform or any other tool, configure and request a certificate, as an example, for domain name request use `*.apps.mycompany.dev` and `apps.mycompany.dev`
- Make sure to create the Route 53 validation records in Route 53

#### Deploy a Shared ALB into a namespace
- Deploy using kubectl or any other tool of your choice the following manifest [manifests/shared-alb-final.template.yaml](manifests/shared-alb-final.template.yaml)
  - This manifest will:
    - Create a blackhole service, optionally, you can create a deployment with a custom `404` or some sort of redirection.
    - Create an ALB
  - You must configure
    - Configure a trusted default deployment `404` or `redirect` image (or use a blackhole service).
    - ACM Certificate ARN
    - ALB Group Name: used to combine ALBs [https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/#group.name](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/#group.name) 

#### Configure a wildcard CNAME to the ALB Hostname
- With the ALB Hostname, within Route 53, select your hosted zone and configure:
  - Wildcard CNAME `*.apps.mycompany.dev` -> `alb-XXX.ca-central-1.elb.amazonaws.com`
  - or setup external DNS in your cluster
    - You will need proper IRSA permissions within the service account that external DNS runs on [https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/integrations/external_dns/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/integrations/external_dns/)

#### Configure a Resource Definition `EKS` in Humanitec
- See [humanitec-terraform/eks.tf](humanitec-terraform/eks.tf)

#### Configure a Resource Definition `Wildcard DNS` in Humanitec
- See [humanitec-terraform/wildcard-dns.tf](humanitec-terraform/wildcard-dns.tf)

#### Configure a Resource Definition `Ingress` in Humanitec
- See [humanitec-terraform/ingress.tf](humanitec-terraform/ingress.tf)

#### Configure an Application in Humanitec
- See [humanitec-terraform/app.tf](humanitec-terraform/app.tf)

Patch the driver (bug in Terraform Provider) to set no TLS. _might not be required_
```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken
curl 'https://api.humanitec.io/orgs/${HUMANITEC_ORG}/resources/defs/myalbingress' \
  -X 'PATCH' \
  -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
  -H "Content-Type: application/json" \
  --data-raw '{"id":"myalbingress","name":"myalbingress","type":"ingress","driver_inputs":{"values":{"no_tls":true}}}'
```

#####  Deploy to Humanitec using Terraform
- Modify `humanitec-terraform/terraform.tfvars.example`
```
cd humanitec-terraform/
terraform init
terraform apply
```

#### Deploy a Score app

This application will create a workload called `backend` along the dependencies for a shared dns `myalbdns` and a ingress `myalbingress` configured earlier.

See [score/score.yaml](score/score.yaml) and [score/extensions.yaml](score/extensions.yaml), and for more details [https://docs.score.dev/docs/reference/humanitec-extension/](https://docs.score.dev/docs/reference/humanitec-extension/) and [https://github.com/score-spec/score-humanitec](https://github.com/score-spec/score-humanitec).

```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export APP_TOKEN="myalb"

score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env development -f score/score.yaml --extensions score/extensions.yaml --deploy
```

Verify `app-development.apps.mycompany.dev` to see your application.
