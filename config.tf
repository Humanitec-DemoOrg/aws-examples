resource "humanitec_resource_definition" "config" {
  driver_type = "humanitec/terraform"
  id          = "${local.app}-config"
  name        = "${local.app}-config"
  type        = "config"

  driver_inputs = {

    secrets_string = jsonencode({
    }),
    values_string = jsonencode(
      {
        append_logs_to_error = true
        script               = <<-EOT
terraform {
  required_providers {
    tfe = {}
  }
}

provider "tfe" {
  token = var.token
  organization  = var.org
}

variable "token" {}
variable "org" {}
variable "project" {}

#this tries to create the project - if it's not there, otherwise fails silenty and that's fine
#we cannot store project in the tfstate as there will be many resources using the same and trying to create and failing
data "http" "create_project" {
  url    = "https://app.terraform.io/api/v2/organizations/${var.org}/projects"
  method = "POST"

  request_headers = {
    "Authorization" : "Bearer ${var.token}",
    "Content-Type" = "application/vnd.api+json"
  }

  request_body = jsonencode({
    "data" : {
      "attributes" : {
        "name" : var.project
      },
      "type" : "projects"
    }
  })
}

data "tfe_project" "p" {
  name         = var.project
  organization = var.org
  depends_on   = [data.http.create_project]
}

resource "tfe_workspace" "w" {
  name         = replace("$${context.app.id}-$${context.env.id}-$${context.res.id}",".","-")
  organization = var.org
  project_id   = data.tfe_project.p.id
}

resource "tfe_workspace_settings" "w" {
  workspace_id   = tfe_workspace.w.id
  execution_mode = "local"
}

output "workspace" {
  value = tfe_workspace.w.name
}

output "org" {
  value = var.org
}

output "project" {
  value = var.project
}


                    EOT
        source               = {}
        variables = {
          token   = var.token
          org     = var.org
          project = "humanitec-$${context.org.id}-$${context.app.id}-$${context.env.id}"
        }
      }
    )
  }

}

resource "humanitec_resource_definition_criteria" "config" {
  resource_definition_id = humanitec_resource_definition.config.id
  app_id                 = local.app
  class                  = "terraform-workspace"
}
