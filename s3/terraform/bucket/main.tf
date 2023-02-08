variable "bucket" {}

resource "aws_s3_bucket" "b" {
  bucket = var.bucket
  tags = {
    Humanitec = true
  }
}

output "parameter" {
  value = aws_s3_bucket.b.bucket
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
