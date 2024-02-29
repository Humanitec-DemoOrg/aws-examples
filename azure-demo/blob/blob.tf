variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "humanitec_host" { default = "https://api.humanitec.io" }
variable "app" {}

variable "resource_group_name" {}
variable "azure_subscription_id" {}
variable "azure_subscription_tenant_id" {}
variable "service_principal_id" {}
variable "region" {}
variable "password" {}

terraform {
  required_providers {
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
}

provider "humanitec" {
  org_id = var.humanitec_organization
  token  = var.humanitec_token
  host   = var.humanitec_host
}

resource "humanitec_application" "app" {
  id   = var.app
  name = var.app
}

resource "humanitec_resource_definition" "azure-blob" {
  driver_type = "humanitec/terraform"
  id          = "${var.app}-azure-blob"
  name        = "${var.app}-azure-blob"
  type        = "azure-blob"
  driver_inputs = {
    secrets_string = jsonencode({
      variables = {
        credentials = {
          azure_subscription_id        = var.azure_subscription_id
          azure_subscription_tenant_id = var.azure_subscription_tenant_id
          service_principal_id         = var.service_principal_id
          service_principal_password   = var.password
      } }
    }),
    values_string = jsonencode(
      {
        append_logs_to_error = true
        source = {
          path = "resources/terraform/azure-blob/"
          rev  = "refs/heads/main"
          url  = "https://github.com/Humanitec-DemoOrg/azure-reference-architecture.git"
        }
        variables = {
          storage_account_location = var.region
          resource_group_name      = var.resource_group_name
        }
      }
    )
  }
}

resource "humanitec_resource_definition_criteria" "azure-blob" {
  resource_definition_id = humanitec_resource_definition.azure-blob.id
  app_id                 = var.app
  class                  = "default"
}
