
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "assume_role_arn" { default = "" }

terraform {
  required_providers {
    postgresql = {
      source  = "doctolib/postgresql"
      version = "2.21.99"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  dynamic "assume_role" {
    for_each = (var.assume_role_arn == "") == true ? [] : [1]
    content {
      role_arn = var.assume_role_arn
    }
  }
}
