variable "app" {}
variable "env" {}
variable "res" {}
variable "name" {}
variable "policies" { type = set(string) }

variable "service_account" {}
variable "cluster_name" {}
variable "namespace" {}

locals {
  name = substr(replace(replace(replace(replace(var.name, "modules.", ""), "shared.", "-s-"), "externals.", ""), ".", ""), 0, 63)
}
output "arn" {
  value = aws_iam_role.this.arn
}

variable "region" {}
variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_iam_role_policy_attachment" "policies" {
  for_each   = var.policies
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role" "this" {
  name = local.name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "pods.eks.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.this.arn
}
