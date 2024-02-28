resource "humanitec_resource_definition" "s3" {
  driver_type = "humanitec/echo"
  id          = "config-s3"
  name        = "config-s3"
  type        = "s3"

  driver_inputs = {
    secrets_string = jsonencode({
      "aws_access_key_id" : "$${resources.config.outputs.user}"
      "aws_secret_access_key" : "$${resources.config.outputs.password}"
    })
    values_string = jsonencode({
      "bucket" : "$${resources.config.outputs.bucket}"
      "region" : "$${resources.config.outputs.region}"
    })
  }
}
