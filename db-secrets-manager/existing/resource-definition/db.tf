resource "humanitec_resource_definition" "postgres" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "existing-postgres"
  name        = "existing-postgres"
  type        = "postgres"


  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "db-secrets-manager/existing/terraform"
          rev  = "refs/heads/main"
          url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
        }
      )
      # Create an AWS Secrets Manager Secret with the following settings /db/myrds
      # assumes an instance is running, if you need to create one from scratch, refer to the source above and adjust accordingly
      # {
      #    "endpoint":"instancename.random-strinh.ca-central-1.rds.amazonaws.com",
      #    "password":"...",
      #    "username":"postgres",
      #    "database":"postgres"
      # }
      "variables" = jsonencode(
        {
          region                 = var.region
          postgres_master_secret = "/db/myrds"
          new_db_name            = "$${context.app.id}-$${context.env.id}"
          new_db_user            = "$${context.app.id}-$${context.env.id}"
          new_db_secret          = "/db/$${context.app.id}/$${context.env.id}"
        }
      )
    }
  }

  lifecycle {
    ignore_changes = [
      criteria
    ]
  }
}

resource "humanitec_resource_definition_criteria" "postgres" {
  resource_definition_id = humanitec_resource_definition.postgres.id
  app_id                 = humanitec_application.app.id
  class                  = "default"
}
