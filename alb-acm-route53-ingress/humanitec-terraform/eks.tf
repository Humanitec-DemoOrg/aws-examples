variable "region" {}
variable "eks_name" {}
variable "eks_resource_name" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "eks_proxy_url" { default = "" }

resource "humanitec_resource_definition" "eks" {
  id          = var.eks_resource_name
  name        = var.eks_resource_name
  type        = "k8s-cluster"
  driver_type = "humanitec/k8s-cluster-eks"

  driver_inputs = {
    values = {
      "loadbalancer" : "${var.region}",
      "loadbalancer_hosted_zone" : "${var.region}",
      "name" : "${var.eks_name}",
      "proxy_url" : "${var.eks_proxy_url}",
      "region" : "${var.region}"
    }
    secrets = {
      "credentials" = jsonencode({
        "aws_access_key_id" : var.aws_access_key_id,
        "aws_secret_access_key" : var.aws_secret_access_key
      })
    }
  }

  criteria = [
    {
      app_id = humanitec_application.app.id
    }
  ]
}
