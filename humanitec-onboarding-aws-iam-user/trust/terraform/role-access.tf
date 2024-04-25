// This role is for Humanitec to access to your AWS Resources (to create S3, RDS, etc)

resource "aws_iam_role" "humanitec_role_access" {
  name        = join("-", ["humanitec-resource-access", data.aws_caller_identity.current.account_id])
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
            "sts:ExternalId" = local.external_id_access
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
            "sts:ExternalId" = local.external_id_access
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
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

output "humanitec_role_arn_ACCESS" {
  description = "Humanitec IAM Access Role ARN - Resource Access"
  value       = aws_iam_role.humanitec_role_access.arn
}

output "humanitec_external_id_ACCESS" {
  description = "Humanitec External ID for secure access - Resource Access"
  value       = local.external_id_access
}
