variable "namespace_resource_name" {}

resource "humanitec_resource_definition" "namespace" {
  id          = var.namespace_resource_name
  name        = var.namespace_resource_name
  type        = "k8s-namespace"
  driver_type = "humanitec/template"

  driver_inputs = {
    values_string = jsonencode({

      templates = {
        init      = ""
        manifests = <<EOL
namespace:
  location: cluster
  data:
    apiVersion: v1
    kind: Namespace
    metadata:
      name: $${context.app.id}-$${context.env.id}

EOL
        outputs   = <<EOL
namespace: $${context.app.id}-$${context.env.id}
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
