variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "humanitec_host" { default = "https://api.humanitec.io" }
variable "app" {}



locals {
  app = var.app
}

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
  host   = var.humanitec_host
}

resource "humanitec_application" "app" {
  id   = local.app
  name = local.app
}
