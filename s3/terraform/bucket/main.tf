variable "bucket" {}

resource "aws_s3_bucket" "b" {
  bucket = var.bucket
  tags = {
    Humanitec = true
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
