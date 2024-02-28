resource "humanitec_resource_definition" "workload_frontend_sa" {
  driver_type = "humanitec/template"
  id          = "${local.app}-frontend-sa"
  name        = "${local.app}-frontend-sa"
  type        = "k8s-service-account"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = <<EOL
name: ${local.app}-frontend-sa
EOL
        manifests = <<EOL
serviceaccount.yaml:
  location: namespace
  data:
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: {{ .init.name }}
EOL
        outputs   = <<EOL
name: {{ .init.name }}
EOL
        cookie    = ""
      }
    })
    secrets_string = jsonencode({
    })
  }
}

resource "humanitec_resource_definition_criteria" "workload_frontend_sa" {
  resource_definition_id = humanitec_resource_definition.workload_frontend_sa.id
  app_id                 = humanitec_application.app.id
  res_id                 = "modules.frontend"
}
