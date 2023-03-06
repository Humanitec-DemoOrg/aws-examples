data "aws_caller_identity" "current" {}

variable "humanitec_user_name" {
  description = "IAM User Name"
  type        = string
  default     = "humanitec"
}

variable "humanitec_saas_policy_name" {
  description = "Policy Name"
  type        = string
  default     = "HumanitecSaaS"
}

// ---

output "humanitec_saas_user" {
  description = "IAM User"
  value       = aws_iam_user.humanitec_saas_user.arn
}

output "humanitec_saas_policy" {
  description = "IAM Policy and Boundary"
  value       = aws_iam_policy.humanitec_saas_policy.arn
}

// ---

resource "aws_iam_user" "humanitec_saas_user" {
  name                 = var.humanitec_user_name
  permissions_boundary = aws_iam_policy.humanitec_saas_policy.arn
}

resource "aws_iam_access_key" "humanitec_saas_user" {
  user = aws_iam_user.humanitec_saas_user.name
}

resource "aws_iam_user_policy_attachment" "humanitec_saas_user" {
  user       = aws_iam_user.humanitec_saas_user.name
  policy_arn = aws_iam_policy.humanitec_saas_policy.arn
}

// ---

resource "aws_iam_policy" "humanitec_saas_policy" {

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = var.humanitec_saas_policy_name
  path        = "/"
  description = "Humanitec SaaS access v0.0.5"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "EKSAccess",
          "Effect" : "Allow",
          "Action" : [
            "eks:DescribeNodegroup",
            "eks:ListNodegroups",
            "eks:AccessKubernetesApi",
            "eks:DescribeCluster",
            "eks:ListClusters"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "aws:ResourceTag/Humanitec" : "true"
            }
          }
        },
        {
          "Sid" : "AssumeRole",
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Resource" : "arn:aws:iam::*:role/humanitec*"
        },
        {
          "Sid" : "HumanitecSaaSAccessOnly",
          "Effect" : "Deny",
          "Action" : "*",
          "Resource" : "*",
          "Condition" : {
            "NotIpAddress" : {
              "aws:SourceIp" : [
                "34.159.97.57/32",
                "35.198.74.96/32",
                "34.141.77.162/32",
                "34.89.188.214/32",
                "34.159.140.35/32",
                "34.89.165.141/32"
              ]
            },
            "Bool" : {
              "aws:ViaAWSService" : "false"
            }
          }
        }
      ]
    }
  )
}
