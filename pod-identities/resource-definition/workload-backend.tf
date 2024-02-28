resource "humanitec_resource_definition" "workload_backend" {
  driver_type = "humanitec/template"
  id          = "${local.app}-backend-workload"
  name        = "${local.app}-backend-workload"
  type        = "workload"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = "role: $${resources.aws-role.outputs.arn}"
        manifests = ""
        outputs   = <<EOL
update:
    - op: add
      path: /spec/serviceAccountName
      value: $${resources.k8s-service-account.outputs.name}
EOL
        cookie    = ""
      }
    }),
    secrets_string = jsonencode({
    })
  }

}

resource "humanitec_resource_definition_criteria" "workload_backend" {
  resource_definition_id = humanitec_resource_definition.workload_backend.id
  app_id                 = humanitec_application.app.id
  res_id                 = "modules.backend"
}
