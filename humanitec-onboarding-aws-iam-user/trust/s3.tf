variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "humanitec_host" { default = "https://api.humanitec.io" }
variable "app" {}
variable "region" {}
variable "driver_account" {}

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

resource "humanitec_resource_definition" "s3" {
  driver_type    = "humanitec/terraform"
  id             = "${local.app}-s3"
  name           = "${local.app}-s3"
  type           = "s3"
  driver_account = var.driver_account
  driver_inputs = {

    secrets_string = jsonencode({
    }),
    values_string = jsonencode(
      {
        append_logs_to_error = true
        credentials_config = {
          "variables" : {
            "ACCESS_KEY_ID" : "AccessKeyId",
            "ACCESS_KEY_VALUE" : "SecretAccessKey",
            "SESSION_TOKEN" : "SessionToken"
          },
          "environment" = {
          }
        }
        script = <<-EOT

                        provider "aws" {
                          region     = var.region
                          access_key = var.ACCESS_KEY_ID
                          secret_key = var.ACCESS_KEY_VALUE
                          token      = var.SESSION_TOKEN
                        }

                        variable "ACCESS_KEY_ID" {}
                        variable "ACCESS_KEY_VALUE" {}
                        variable "SESSION_TOKEN" {}

                        variable "bucket_name" {}
                        variable "region" {}

                        resource "aws_s3_bucket" "s3" {
                          bucket_prefix = var.bucket_name
                        }

                        output "bucket" {
                          value = aws_s3_bucket.s3.bucket
                        }
 
                        output "region" {
                          value = var.region
                        }
                    EOT
        source = {}
        variables = {
          bucket_name = "someniceprefix"
          region      = var.region
        }
      }
    )
  }

}

resource "humanitec_resource_definition_criteria" "s3" {
  resource_definition_id = humanitec_resource_definition.s3.id
  app_id                 = local.app
  class                  = "default"
}
