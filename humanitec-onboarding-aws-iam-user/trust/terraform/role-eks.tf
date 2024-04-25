// This role is for Humanitec to access to your Clusters

resource "aws_iam_role_policy" "humanitec_policy_eks" {
  name_prefix = join("-", ["humanitec-eks-access", data.aws_caller_identity.current.account_id])
  role        = aws_iam_role.humanitec_role_eks.id

  policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "HumanitecEKSAccess",
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
      }
    ]
  })
}
resource "aws_iam_role" "humanitec_role_eks" {
  name        = join("-", ["humanitec-eks-access", data.aws_caller_identity.current.account_id])
  description = local.description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::767398028804:user/humanitec"
          ]
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.external_id_eks
          }
        }
      },
      {
        Effect = "Deny"
        Principal = {
          AWS = [
            "arn:aws:iam::767398028804:user/humanitec"
          ]
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.external_id_eks
          }
          NotIpAddress = {
            "aws:SourceIp" = data.humanitec_source_ip_ranges.main.cidr_blocks
          }
          Bool = {
            "aws:ViaAWSService" = false
          }
        }
      }
    ]
  })
}

output "humanitec_role_EKS" {
  description = "Humanitec IAM Access Role ARN - EKS"
  value       = aws_iam_role.humanitec_role_eks.arn
}

output "humanitec_external_id_EKS" {
  description = "Humanitec External ID for secure access - EKS"
  value       = local.external_id_eks
}
