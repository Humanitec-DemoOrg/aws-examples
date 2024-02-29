terraform {
  required_providers {
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
}
variable "humanitec_org" {}
variable "humanitec_token" {}

provider "humanitec" {
  org_id = var.humanitec_org
  token  = var.humanitec_token
}

variable "humanitec_app" {}
resource "humanitec_application" "app" {
  id   = var.humanitec_app
  name = var.humanitec_app
}

variable "driver_account" {}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "The location of the bucket"
  type        = string
}
