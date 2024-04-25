variable "humanitec_organization" {}
variable "humanitec_token" {}

terraform {
  required_providers {
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
}

provider "humanitec" {
  org_id = var.humanitec_organization
  token  = var.humanitec_token
}

data "aws_caller_identity" "current" {}

resource "random_uuid" "external_id_eks" {
}

resource "random_uuid" "external_id_access" {
}

locals {
  external_id_eks    = random_uuid.external_id_eks.result
  external_id_access = random_uuid.external_id_access.result
  account            = data.aws_caller_identity.current.account_id
  description        = "Connect your AWS account with Humanitec to manage resources on your behalf. Updated April 2024."
}

data "humanitec_source_ip_ranges" "main" {}
data "aws_region" "current" {}
