variable "app" {}
variable "env" {}
variable "res" {}
variable "name" {}

locals {
  name = substr(replace(replace(replace(replace(var.name, "modules.", ""), "shared.", "-s-"), "externals.", ""), ".", ""), 0, 63)
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

variable "region" {}
variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = local.name
}
