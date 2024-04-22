resource "humanitec_resource_definition" "base-env" {
  driver_type = "humanitec/template"
  id          = "${var.app_id}-base-env"
  name        = "${var.app_id}-base-env"
  type        = "base-env"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = ""
        manifests = <<EOL
namespace-rbac:
  location: namespace
  data:
    apiVersion: rbacmanager.reactiveops.io/v1beta1
    kind: RBACDefinition
    metadata:
      name: rbac-$${context.app.id}-$${context.env.id}
    rbacBindings:
      - name: dev-team
        subjects:
          - kind: Group
            name: dev-team
        roleBindings:
          - clusterRole: edit
            namespaceSelector:
              matchLabels:
                team: $${context.app.id}
                env: development
      - name: admin-team
        subjects:
          - kind: Group
            name: admin-team
        roleBindings:
          - clusterRole: edit
            namespaceSelector:
              matchLabels:
                team: $${context.app.id}
EOL
        outputs   = ""
        cookie    = ""
      }
    })
    secrets_string = jsonencode({
      templates = {
        outputs = <<EOL
EOL
      }
    })
  }

}

resource "humanitec_resource_definition_criteria" "base-env" {
  resource_definition_id = humanitec_resource_definition.base-env.id
  app_id                 = humanitec_application.app.id
}
