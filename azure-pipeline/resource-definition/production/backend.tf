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


provider "humanitec" {
  org_id = var.HUMANITEC_ORG
  token  = var.HUMANITEC_TOKEN
}

variable "HUMANITEC_APP" {}
variable "HUMANITEC_ENV" {}
