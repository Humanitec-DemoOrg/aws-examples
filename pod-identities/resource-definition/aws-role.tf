
resource "humanitec_resource_definition" "role" {
  id          = "${local.app}-role"
  name        = "${local.app}-role"
  type        = "aws-role"
  driver_type = "humanitec/terraform"

  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        access_key = var.access_key
        secret_key = var.secret_key
        region     = var.region
      }
    }),

    values_string = jsonencode({
      "script" = file("${path.module}/source/role.tf")
      "variables" = {

        policies = "$${resources.workload>aws-policy.outputs.arn}"
        name     = "$${context.app.id}-$${context.env.id}-$${context.res.id}"

        namespace       = "$${resources.k8s-namespace.outputs.namespace}"
        cluster_name    = "$${resources.k8s-cluster.outputs.name}"
        service_account = "$${resources.k8s-service-account.outputs.name}"

        app = "$${context.app.id}"
        env = "$${context.env.id}"
        res = "$${context.res.id}"

      }

    })
  }
}

resource "humanitec_resource_definition_criteria" "role" {
  resource_definition_id = humanitec_resource_definition.role.id
  app_id                 = humanitec_application.app.id
}
