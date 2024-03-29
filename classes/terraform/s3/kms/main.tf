variable "bucket" {}

locals {
  sanitized_name   = replace(replace(replace(replace(lower(var.bucket), "modules.", ""), ".externals.", "."), "/[^a-z\\-0-9]/", "-"), "/-*$/", "") #https://github.com/edgelaboratories/terraform-short-name/blob/main/main.tf
  name_is_too_long = length(local.sanitized_name) > 63
  truncated_name   = replace(substr(local.sanitized_name, 0, 63 - 1 - 0), "/-*$/", "")
  name             = local.name_is_too_long ? local.truncated_name : local.sanitized_name
}

resource "aws_s3_bucket" "b" {
  bucket = local.name
  tags = {
    Humanitec = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "b" {
  bucket = aws_s3_bucket.b.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

output "bucket" {
  value = aws_s3_bucket.b.bucket
}

output "region" {
  value = var.region
}

output "aws_access_key_id" {
  value     = ""
  sensitive = true
}

output "aws_secret_access_key" {
  value     = ""
  sensitive = true
}

// boilerplate for Humanitec tofu driver
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "assume_role_arn" { default = "" }

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
  dynamic "assume_role" {
    for_each = (var.assume_role_arn == "") == true ? [] : [1]
    content {
      role_arn = var.assume_role_arn
    }
  }
}
