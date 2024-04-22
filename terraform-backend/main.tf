variable "humanitec_organization" { default = "HUMANITEC_ORGANIZATION" }
variable "humanitec_token" { default = "HUMANITEC_TOKEN" }
variable "region" { default = "ca-central-1" }
variable "access_key" { default = "AKIAIOSFODNN7EXAMPLE" }
variable "secret_key" { default = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" }

variable "state_bucket" { default = "humanitec-tf-state-example" }
variable "state_table" { default = "humanitec-tf-state-example" }
variable "state_role" { default = "arn:aws:iam::<<ACCOUNT_ID>>:role/humanitec-tf-state-example" }
variable "state_external_id" { default = "<<SOME-KNOWN-EXTERNAL-ID>>" }
variable "state_region" { default = "ca-central-1" }

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

resource "humanitec_resource_definition_criteria" "aws_terraform_resource_s3_bucket" {
  resource_definition_id = humanitec_resource_definition.aws_terraform_resource_s3_bucket.id
  res_id                 = null
}

resource "humanitec_resource_definition" "aws_terraform_resource_s3_bucket" {
  driver_type = "humanitec/terraform"
  id          = "aws-terrafom-s3-bucket"
  name        = "aws-terrafom-s3-bucket"
  type        = "s3"

  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        access_key = var.access_key
        secret_key = var.secret_key
      }
    }),
    values_string = jsonencode({
      "script" = <<EOL
terraform {
  backend "s3" {
    access_key     = "${var.access_key}"
    secret_key     = "${var.secret_key}"
    bucket         = "${var.state_bucket}"
    key            = "$${context.app.id}-$${context.env.id}/$${context.res.id}"
    region         = "${var.state_region}"
    dynamodb_table = "${var.state_table}"
    external_id    = "${var.state_external_id}"
    role_arn       = "${var.state_role}"
    session_name   = "<<HUMANITEC-SAAS-ACCESS-EXAMPLE-TO-TF-BUCKET>>"
  }
}
EOL
      "source" = {
        path = "s3/terraform/bucket/"
        rev  = "refs/heads/main"
        url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
      }

      "variables" = {
        region                   = var.region,
        bucket                   = "my-bucket-$${context.app.id}-$${context.env.id}"
        assume_role_arn          = "arn:aws:iam::ACCOUNT_ID:role/<<HUMANITEC-ROLE-NAME-FOR-S3>>"
        assume_role_session_name = "<<HUMANITEC-SAAS-ACCESS-EXAMPLE-TO-S3>>"
        assume_role_external_id  = "<<SOME-KNOWN-EXTERNAL-ID>>"
      }

    })
  }

}
