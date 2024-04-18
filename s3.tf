resource "humanitec_resource_definition" "s3" {
  driver_type = "humanitec/terraform"
  id          = "${local.app}-s3"
  name        = "${local.app}-s3"
  type        = "s3"

  driver_inputs = {

    secrets_string = jsonencode({
      terraform = {
        tokens = {
          app_terraform_io = var.token
        }
      }
    }),
    values_string = jsonencode(
      {
        append_logs_to_error = true
        script               = <<-EOT

terraform {
  cloud {
    organization = "$${resources["config.terraform-workspace"].outputs.org}"

    workspaces {
      name ="$${resources["config.terraform-workspace"].outputs.workspace}"
    }
  }
}
variable "workspace" {}

output "bucket" {
  value = var.workspace
}

                    EOT
        source               = {}
        variables = {
          workspace = "$${resources['config.terraform-workspace'].outputs.workspace}"
        }
      }
    )
  }

}

resource "humanitec_resource_definition_criteria" "s3" {
  resource_definition_id = humanitec_resource_definition.s3.id
  app_id                 = local.app
  class                  = "default"
}
