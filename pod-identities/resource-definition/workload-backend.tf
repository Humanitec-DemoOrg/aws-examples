resource "humanitec_resource_definition" "workload_backend_sa" {
  driver_type = "humanitec/template"
  id          = "${local.app}-backend-sa"
  name        = "${local.app}-backend-sa"
  type        = "k8s-service-account"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = <<EOL
name: ${local.app}-backend-sa
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
  lifecycle {
    ignore_changes = [
      criteria
    ]
  }
}

resource "humanitec_resource_definition_criteria" "workload_backend_sa" {
  resource_definition_id = humanitec_resource_definition.workload_backend_sa.id
  app_id                 = humanitec_application.app.id
  res_id                 = "modules.backend"
}


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

  lifecycle {
    ignore_changes = [
      criteria
    ]
  }

}

resource "humanitec_resource_definition_criteria" "workload_backend" {
  resource_definition_id = humanitec_resource_definition.workload_backend.id
  app_id                 = humanitec_application.app.id
  res_id                 = "modules.backend"
}
