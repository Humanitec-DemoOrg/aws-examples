resource "humanitec_resource_definition" "postgres_dev" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_id}-generic-postgres"
  name        = "${var.app_id}-generic-postgres"
  type        = "postgres"

  driver_inputs = {
    secrets = {
      variables = jsonencode({

      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "terraform-training/postgres/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          username = "$${resources.base-env.outputs.db_username}"
          size     = "$${resources.base-env.outputs.db_instance_size}"
        }
      )
    }
  }

  criteria = [
    {
      app_id = var.app_id
    }
  ]

}
