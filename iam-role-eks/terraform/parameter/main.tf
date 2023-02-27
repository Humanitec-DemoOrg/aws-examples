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

output "parameter_arn" {
  value = aws_ssm_parameter.test.arn
}

output "parameter_name" {
  value = aws_ssm_parameter.test.name
}

# this does not exist for this resource type, we default to name for output consistency
output "parameter_id" {
  value = aws_ssm_parameter.test.name
}

// boilerplate for Humanitec terraform driver
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "assume_role_arn" {}
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
  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
