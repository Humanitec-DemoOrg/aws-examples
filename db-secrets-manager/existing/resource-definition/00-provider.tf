variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "humanitec_host" { default = "https://api.humanitec.io" }

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
