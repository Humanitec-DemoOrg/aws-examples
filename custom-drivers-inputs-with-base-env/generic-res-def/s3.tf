resource "humanitec_resource_definition" "s3" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_id}-generic-s3"
  name        = "${var.app_id}-generic-s3"
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
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          aws_role = "$${resources.base-env.outputs.aws_role}"
          bucket   = "$${resources.base-env.outputs.bucket_prefix}-$${context.app.id}-$${context.env.id}"
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
