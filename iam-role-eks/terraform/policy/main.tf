variable "policy_ssm_name" {
  default = "humanitec-"
}

resource "aws_iam_policy" "policy_ssm" {
  name_prefix = var.policy_ssm_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "SSMGeneral",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "ssm:resourceTag/Humanitec" : "true"
          }
        }
      }
    ]
  })
  tags = {
    Humanitec = "true"
  }
}

output "policy_ssm" {
  value = aws_iam_policy.policy_ssm.arn
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
