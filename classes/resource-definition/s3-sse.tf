resource "humanitec_resource_definition" "s3_sse" {
  driver_type = "humanitec/terraform"
  id          = "s3-sse"
  name        = "s3-sse"
  type        = "s3"

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "classes/terraform/s3/sse/"
          rev  = "refs/heads/main"
          url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region = var.region
          bucket = "$${context.app.id}-$${context.env.id}-$${context.res.id}"
        }
      )
    }
  }

}
