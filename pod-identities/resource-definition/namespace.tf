resource "humanitec_resource_definition" "namespace" {
  id          = "${local.app}-namespace"
  name        = "${local.app}-namespace"
  type        = "k8s-namespace"
  driver_type = "humanitec/template"

  driver_inputs = {
    values_string = jsonencode({

      templates = {
        init      = "name: $${context.app.id}-$${context.env.id}"
        manifests = <<EOL
namespace:
  location: cluster
  data:
    apiVersion: v1
    kind: Namespace
    metadata:
      name: {{ .init.name }}
EOL
        outputs   = <<EOL
namespace: {{ .init.name }}
EOL
        cookie    = ""
      }
    })

  }
}

resource "humanitec_resource_definition_criteria" "namespace" {
  resource_definition_id = humanitec_resource_definition.namespace.id
  app_id                 = humanitec_application.app.id
  res_id                 = "k8s-namespace"
}
