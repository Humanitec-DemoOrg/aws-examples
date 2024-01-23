resource "humanitec_resource_definition" "s3ro" {
  driver_type = "humanitec/terraform"
  id          = "${local.app}-s3ro"
  name        = "${local.app}-s3ro"
  type        = "s3"

  provision = {
    "aws-policy.s3ro" = {
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
  lifecycle {
    ignore_changes = [
      criteria
    ]
  }

}

resource "humanitec_resource_definition_criteria" "s3ro" {
  resource_definition_id = humanitec_resource_definition.s3ro.id
  app_id                 = humanitec_application.app.id
  env_id                 = "development"
  class                  = "mys3ro"
}
