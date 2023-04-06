resource "humanitec_resource_definition" "aws_terraform_resource_workload1_sa1" { // one SA per Workload

  driver_type = "humanitec/template"
  id          = "${var.app_name}-${var.workload}-sa"
  name        = "${var.app_name}-${var.workload}-sa"
  type        = "k8s-service-account"

  // use new https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria
  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "modules.${var.workload}"
    }
  ]

  driver_inputs = {
    values = {
      templates = jsonencode({
        init      = <<EOL
name: ${var.app_name}-${var.workload}-sa
EOL
        manifests = <<EOL
serviceaccount.yaml:
  location: namespace
  data:
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: {{ .init.name }}
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/S3Access
EOL
        outputs   = <<EOL
name: {{ .init.name }}
EOL
        cookie    = ""
      })
    }
    secrets = {
    }
  }
}

resource "humanitec_resource_definition" "aws_terraform_resource_workload1" {
  // a Workload attaches the service account
  // you can only have one workload resource per workload
  driver_type = "humanitec/template"
  id          = "${var.app_name}-${var.workload}-workload"
  name        = "${var.app_name}-${var.workload}-workload"
  type        = "workload"

  // use new https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria
  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "modules.${var.workload}"
    }
  ]

  driver_inputs = {
    values = {
      templates = jsonencode({
        init      = <<EOL
EOL
        manifests = <<EOL
EOL
        outputs   = <<EOL
update:
    - op: add
      path: /spec/serviceAccountName
      value: $${resources.k8s-service-account.outputs.name}
EOL
        cookie    = ""
      })
    }
    secrets = {
    }
  }
}
