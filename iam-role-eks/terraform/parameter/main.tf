variable "parameter_name" { default = "/humanitec/test" }
variable "parameter_value" { default = "my test value" }

resource "aws_ssm_parameter" "test" {
  name      = var.parameter_name
  type      = "String"
  value     = var.parameter_value
  overwrite = true
  tags = {
    Humanitec = "true"
  }
}
output "parameter" {
  value = aws_ssm_parameter.test.arn
}

// boilerplate for Humanitec terraform driver
variable "region" {}
variable "access_key" {}
variable "secret_key" {}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
