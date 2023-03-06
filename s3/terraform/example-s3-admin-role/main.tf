provider "aws" {
  default_tags {
    tags = {
      Humanitec = "true"
    }
  }
}

variable "source_account" {}
variable "external_id" {}
variable "role_name" {}

output "role" {
  value = aws_iam_role.default.arn
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "AWS"
      identifiers = [var.source_account == "" ? data.aws_caller_identity.current.account_id : var.source_account]
    }

    dynamic "condition" {
      for_each = (var.external_id == "") == true ? [] : [1]
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.external_id == "" ? data.aws_caller_identity.current.account_id : var.external_id]
      }
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "default" {
  name                  = var.role_name
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
