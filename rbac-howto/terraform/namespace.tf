resource "humanitec_resource_definition" "namespace" {
  id          = "${var.app_id}-namespace"
  name        = "${var.app_id}-namespace"
  type        = "k8s-namespace"
  driver_type = "humanitec/template"

  driver_inputs = {
    values = {

      templates = jsonencode({
        init      = ""
        manifests = <<EOL
namespace:
  location: cluster
  data:
    apiVersion: v1
    kind: Namespace
    metadata:
      name: $${context.app.id}-$${context.env.id}
      labels:
        team: $${context.app.id}
        env: $${context.env.id}

EOL
        outputs   = <<EOL
namespace: $${context.app.id}-$${context.env.id}
EOL
        cookie    = ""
      })
    }
    secrets = {
    }
  }

  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "k8s-namespace"
    }
  ]
}
