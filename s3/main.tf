variable "humanitec_organization" { default = "HUMANITEC_ORGANIZATION" }
variable "humanitec_token" { default = "HUMANITEC_TOKEN" }
variable "region" { default = "ca-central-1" }
variable "access_key" { default = "AKIAIOSFODNN7EXAMPLE" }
variable "secret_key" { default = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" }


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

resource "humanitec_resource_definition" "aws_terraform_resource_s3_bucket" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "aws-terrafom-s3-bucket"
  name        = "aws-terrafom-s3-bucket"
  type        = "s3"

  criteria = [
    {
      res_id = null
    }
  ]

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "s3/terraform/bucket/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region                   = var.region,
          bucket                   = "my-company-my-app-$${context.app.id}-$${context.env.id}",
          assume_role_arn          = "arn:aws:iam::ACCOUNT_ID:role/<<HUMANITEC-ROLE-NAME-FOR-S3>>"
          assume_role_session_name = "<<HUMANITEC-SAAS-ACCESS-EXAMPLE-TO-S3>>"
          assume_role_external_id  = "<<SOME-KNOWN-EXTERNAL-ID>>"
        }
      )
    }
  }

}
