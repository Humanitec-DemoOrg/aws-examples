provider "aws" {
  default_tags {
    tags = {
      Humanitec = "true"
    }
  }
}

variable "name" { default = "humanitec-tf-state" }
variable "source_account" { default = "" }
variable "external_id" { default = "" }

resource "random_id" "r" {
  byte_length = 4
}

locals {
  name = "${var.name}-${random_id.r.dec}"
}
data "aws_caller_identity" "current" {}

output "role" {
  value = aws_iam_role.r.arn
}
output "bucket_arn" {
  value = aws_s3_bucket.b.arn
}
output "bucket_name" {
  value = aws_s3_bucket.b.bucket
}
output "table" {
  value = aws_dynamodb_table.t.arn
}
output "table_name" {
  value = aws_dynamodb_table.t.name
}

// ---

resource "aws_s3_bucket" "b" {
  bucket        = local.name
  force_destroy = true

}
resource "aws_s3_bucket_acl" "b" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "b" {
  bucket = aws_s3_bucket.b.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket                  = aws_s3_bucket.b.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "b" {
  bucket = aws_s3_bucket.b.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// ---

resource "aws_dynamodb_table" "t" {
  name         = local.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled = true
  }
}

// ---

resource "aws_iam_policy" "p" {
  name = local.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "${aws_s3_bucket.b.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        "Resource" : "${aws_s3_bucket.b.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        "Resource" : "${aws_dynamodb_table.t.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "p" {
  role       = aws_iam_role.r.name
  policy_arn = aws_iam_policy.p.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "AWS"
      identifiers = [var.source_account == "" ? data.aws_caller_identity.current.account_id : var.source_account]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id == "" ? data.aws_caller_identity.current.account_id : var.external_id]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "r" {
  name                  = local.name
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  force_detach_policies = true
}
