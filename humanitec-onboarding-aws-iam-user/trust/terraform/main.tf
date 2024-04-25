// Role - trust role
// This create 2 roles - one for EKS access and One for AWS Resources (like s3, rds, etc)

//see role-eks.tf
//see role-access.tf

// ROLE Registered as Cloud Account in Humanitec
resource "humanitec_resource_account" "account_access" { //this role is for drivers, like s3 and rds
  id          = "${local.account}-access"
  name        = "${local.account}-access"
  type        = "aws-role"
  credentials = jsonencode({ "external_id" : local.external_id_access, "aws_role" : aws_iam_role.humanitec_role_access.arn })
}

resource "humanitec_resource_account" "account_eks" { //this role is for EKS clusters
  id          = "${local.account}-eks"
  name        = "${local.account}-eks"
  type        = "aws-role"
  credentials = jsonencode({ "external_id" : local.external_id_eks, "aws_role" : aws_iam_role.humanitec_role_eks.arn })
}

// PRIVATE KEY for agent and exported locally - store somewhere safe
resource "tls_private_key" "agent_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key_pem" {
  content  = tls_private_key.agent_private_key.private_key_pem //use this for Helm
  filename = "${path.module}/humanitec_agent_private_key.pem"
}
resource "local_file" "private_key_base64" { // this this in your ConfigMap/manifest directly
  content  = base64encode(tls_private_key.agent_private_key.private_key_pem)
  filename = "${path.module}/humanitec_agent_private_key.pem.b64"
}

// REGISTER AGENT with humanitec
variable "agent_id" {
  default = "my-agent-id" //TODO: use the same name of your cluster, append Account ID to make it easier to find
}

resource "humanitec_agent" "agent" {
  id          = var.agent_id
  description = "${var.agent_id} for account ${local.account}"
  public_keys = [
    {
      key = "${tls_private_key.agent_private_key.public_key_pem}"
    }
  ]
}

// App for test
variable "app_name" { default = "myapp" }
resource "humanitec_application" "app" {
  id   = var.app_name
  name = var.app_name
}

// Agent Resource
resource "humanitec_resource_definition" "agent" {
  id   = var.agent_id
  name = var.agent_id
  type = "agent"

  driver_type = "humanitec/agent"
  driver_inputs = {
    values_string = jsonencode({
      id = var.agent_id
    })
  }
}
// TODO: Agent resource matching criteria should match the EKS cluster
resource "humanitec_resource_definition_criteria" "agent" {
  resource_definition_id = humanitec_resource_definition.agent.id
  app_id                 = humanitec_application.app.id
}

// EKS resource
variable "eks_resource_name" {
  default = "my-eks-id" //TODO: use the name of your cluster
}

resource "humanitec_resource_definition" "eks" {
  // SEE BELOW FOR EKS API with `AmazonEKSClusterAdminPolicy` and ConfigMap
  // Make sure your cluster is tagged with "Humanitec: true"

  id          = "${var.eks_resource_name}-${local.account}"
  name        = "${var.eks_resource_name}-${local.account}"
  type        = "k8s-cluster"
  driver_type = "humanitec/k8s-cluster-eks"

  driver_account = humanitec_resource_account.account_eks.name //AWS ROLE ASSUMPTION FOR EKS, see `role-eks.tf`

  driver_inputs = {
    values_string = jsonencode({
      "name" : "${var.eks_resource_name}",
      "region" : "${data.aws_region.current.name}"
    })
    secrets_string = jsonencode({
      "agent_url" = "$${resources.agent.outputs.url}"
    })
  }

}

resource "humanitec_resource_definition_criteria" "eks" {
  resource_definition_id = humanitec_resource_definition.eks.id
  app_id                 = humanitec_application.app.id
}

// TODO: For existing Clusters:

/*
`Agent URL` ${resources.agent.outputs.url}
`Credentials`: enter {} in credentials for existing cluster, leave empty for new clusters
`Proxy URL` empty
*/


// TODO: For existing and new Clusters
/*

One agent per cluster --- USE MANIFEST OR HELM CHART
https://developer.humanitec.com/integration-and-extensions/humanitec-agent/installation/#install

Update AWS in cluster access entries

https://docs.aws.amazon.com/eks/latest/userguide/auth-configmap.html 
https://docs.aws.amazon.com/eks/latest/userguide/grant-k8s-access.html


Install the agent (with the kubernetes manifest or Helm chat) - make sure to export the private from this directory `humanitec_agent_private_key.pem`
*/
