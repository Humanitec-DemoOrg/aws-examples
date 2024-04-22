variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "assume_role_arn" {}
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

resource "humanitec_resource_definition_criteria" "aws_terraform_resource_s3_bucket" {
  resource_definition_id = humanitec_resource_definition.aws_terraform_resource_s3_bucket.id
  app_id                 = humanitec_application.app.id
}

resource "humanitec_resource_definition" "aws_terraform_resource_s3_bucket" {
  driver_type = "humanitec/terraform"
  id          = "${var.app_name}-aws-terrafom-s3-bucket"
  name        = "${var.app_name}-aws-terrafom-s3-bucket"
  type        = "s3"


  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        access_key = var.access_key
        secret_key = var.secret_key
      }
    }),
    values_string = jsonencode({
      "source" = {
        path = "s3/terraform/bucket/"
        rev  = "refs/heads/main"
        url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
      }

      "variables" = {
        region          = var.region,
        bucket          = "my-company-my-app-$${context.app.id}-$${context.env.id}",
        assume_role_arn = var.assume_role_arn
      }

    })
  }

}

# If you are using externals IDs and Session name (recommended), the definition would look like this (depending on your Terraform Code):
# "variables" = jsonencode(
#   {
#     region                   = var.region,
#     bucket                   = "my-company-my-app-$${context.app.id}-$${context.env.id}",
#     assume_role_arn          = "arn:aws:iam::ACCOUNT_ID:role/<<HUMANITEC-ROLE-NAME-FOR-S3>>"
#     assume_role_session_name = "<<HUMANITEC-SAAS-ACCESS-EXAMPLE-TO-S3>>"
#     assume_role_external_id  = "<<SOME-KNOWN-EXTERNAL-ID>>"
#   }
# )
