resource "humanitec_resource_definition_criteria" "gcs-inline" {
  resource_definition_id = humanitec_resource_definition.gcs-inline.id
  class                  = "default"
  app_id                 = var.humanitec_app
}

resource "humanitec_resource_definition" "gcs-inline" {
  driver_type = "humanitec/terraform"
  id          = "${var.humanitec_app}-gcs"
  name        = "${var.humanitec_app}-gcs"
  type        = "gcs"

  driver_account = var.driver_account

  driver_inputs = {

    values_string = jsonencode({
      append_logs_to_error = true
      credentials_config = {
        "file" : "creds.json"
      }

      script = <<-EOT
        variable "project_id" {}
        variable "location" {}
        variable "name" {}

        terraform {
          required_providers {
            google = {
              source = "hashicorp/google"
            }
          }
        }

        provider "google" {
          project     = var.project_id
          credentials = "creds.json"
        }
        
        output "name" {
          value = google_storage_bucket.bucket.name
        }

        resource "google_storage_bucket" "bucket" {
          name          = var.name
          location      = var.location
          force_destroy = true
        }
  EOT
      variables = {
        name       = "$${context.app.id}-$${context.env.id}"
        project_id = var.project
        location   = var.location
      }
    })
  }
}
