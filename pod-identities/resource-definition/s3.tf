resource "humanitec_resource_definition" "s3" {
  driver_type = "humanitec/terraform"
  id          = "${local.app}-s3"
  name        = "${local.app}-s3"
  type        = "s3"

  provision = {
    "aws-policy.s3" = {
      "is_dependent" : true,
      "match_dependents" : true
    }
  }

  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        access_key = var.access_key
        secret_key = var.secret_key
        region     = var.region
      }
    }),
    values_string = jsonencode({
      "script" = file("${path.module}/source/s3.tf")
      "variables" = {
        name = "$${context.app.id}-$${context.env.id}-$${context.res.id}"
        app  = "$${context.app.id}"
        env  = "$${context.env.id}"
        res  = "$${context.res.id}"
      }

    })
  }

}

resource "humanitec_resource_definition_criteria" "s3" {
  resource_definition_id = humanitec_resource_definition.s3.id
  app_id                 = humanitec_application.app.id
  class                  = "mys3"
}
