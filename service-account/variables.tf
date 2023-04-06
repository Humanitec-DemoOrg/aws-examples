variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "humanitec_host" {}


variable "app_name" {}
variable "workload" {}

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
  id   = var.app_name
  name = var.app_name
}
