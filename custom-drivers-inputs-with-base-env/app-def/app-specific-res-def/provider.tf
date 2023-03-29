variable "humanitec_organization" {}
variable "humanitec_token" {}

terraform {
  required_providers {
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
  backend "local" {}
}

provider "humanitec" {
  org_id = var.humanitec_organization
  token  = var.humanitec_token
}
