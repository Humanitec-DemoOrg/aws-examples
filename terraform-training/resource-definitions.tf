variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "app_name" {}
variable "workload" {}

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
}

resource "humanitec_application" "app" {
  id   = var.app_name
  name = var.app_name
}

resource "humanitec_resource_definition" "s3" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-s3"
  name        = "${var.app_name}-s3"
  type        = "s3"

  driver_inputs = {
    secrets = {
    },
    values = {
      "source" = jsonencode(
        {
          path = "humanitec-aws-examples/terraform-training/s3/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region = "ca-central-1"
          bucket = "my-company-my-app-$${context.app.id}-$${context.env.id}"
        }
      )
    }
  }

  criteria = [
    {
      res_id = "modules.${var.workload}.externals.${var.app_name}-s3-resource"
      app_id = humanitec_application.app.id
    }
  ]

}

resource "humanitec_resource_definition" "postgres" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-postgres"
  name        = "${var.app_name}-postgres"
  type        = "postgres"

  driver_inputs = {
    secrets = {
    },
    values = {
      "source" = jsonencode(
        {
          path = "humanitec-aws-examples/terraform-training/postgres/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          name = "mydb"
        }
      )
    }
  }

  criteria = [
    {
      res_id = "modules.${var.workload}.externals.${var.app_name}-postgres-resource"
      app_id = humanitec_application.app.id
    }
  ]

}
