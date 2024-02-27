terraform {
  cloud {
  }
}

terraform {
  required_providers {
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
}

variable "HUMANITEC_ORG" {}
variable "HUMANITEC_TOKEN" {}
variable "HUMANITEC_APP" {}

provider "humanitec" {
  org_id = var.HUMANITEC_ORG
  token  = var.HUMANITEC_TOKEN
}

resource "humanitec_application" "app" {
  id   = var.HUMANITEC_APP
  name = var.HUMANITEC_APP
}
