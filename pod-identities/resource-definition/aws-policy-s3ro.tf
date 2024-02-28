resource "humanitec_resource_definition" "s3ro_policy" {
  driver_type = "humanitec/terraform"
  id          = "${local.app}-s3ro-policy"
  name        = "${local.app}-s3ro-policy"
  type        = "aws-policy"

  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        access_key = var.access_key
        secret_key = var.secret_key
        region     = var.region
      }
    }),
    values_string = jsonencode({
      "script" = file("${path.module}/source/s3ro-policy.tf")
      "variables" = {
        arns = "$${resources['aws-policy.s3ro>s3'].outputs.arn}"
        name = "$${context.app.id}-$${context.env.id}-$${context.res.id}"
        app  = "$${context.app.id}"
        env  = "$${context.env.id}"
        res  = "$${context.res.id}"
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "s3ro_policy" {
  resource_definition_id = humanitec_resource_definition.s3ro_policy.id
  app_id                 = humanitec_application.app.id
  class                  = "s3ro"
}
