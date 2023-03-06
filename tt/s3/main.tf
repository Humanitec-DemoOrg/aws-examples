variable "bucket" {
  default = "mybucket"
}

variable "region" {
  default = "ca-central-1"
}

output "aws_access_key_id" {
  value = ""
}

output "aws_secret_access_key" {
  value = ""
}

output "bucket" {
  value = "arn:aws:s3:::${var.bucket}"
}

output "region" {
  value = var.region
}
