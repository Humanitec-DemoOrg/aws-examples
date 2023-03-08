variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "app_name" {}


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

resource "humanitec_application" "app" {
  id   = var.app_name
  name = var.app_name
}

variable "dev_env" { default = "development" }

variable "stg_env" { default = "staging" }


## ENVIRONMENT TYPES

# this is created by default
# resource "humanitec_environment_type" "development" {
#   id          = var.dev_env
#   description = "development"
# }


# resource "humanitec_environment_type" "staging" {
#   id          = var.stg_env
#   description = "staging"
# }

## APP ENV
# TF provider will be updated soon

# https://api.humanitec.io/orgs/{orgId}/apps/{appId}/envs
