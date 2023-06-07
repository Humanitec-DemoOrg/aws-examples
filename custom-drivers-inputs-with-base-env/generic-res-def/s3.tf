resource "humanitec_resource_definition" "s3" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "generic-res-s3"
  name        = "generic-res-s3"
  type        = "s3"

  driver_inputs = {
    secrets = {
      variables = jsonencode({

      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "terraform-training/s3/"
          rev  = "refs/heads/main"
          url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          aws_role       = "$${resources.base-env.outputs.aws_role}"
          aws_account_id = "$${resources.base-env.outputs.aws_account_id}"
          bucket         = "$${resources.base-env.outputs.bucket_prefix}-$${context.app.id}-$${context.env.id}"
        }
      )
    }
  }

  criteria = [
    {
      app_id = var.app_id
    }
  ]

}
