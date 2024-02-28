resource "humanitec_resource_definition" "s3_dev" {
  driver_type = "humanitec/terraform"
  id          = "${var.app_name}-s3-dev"
  name        = "${var.app_name}-s3-dev"
  type        = "s3"

  driver_inputs = {
    secrets = {
      variables = jsonencode({

      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "terraform-training/s3/"
          rev  = "refs/heads/main"
          url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
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

}

resource "humanitec_resource_definition_criteria" "s3_dev" {
  resource_definition_id = humanitec_resource_definition.s3_dev.id
  app_id                 = humanitec_application.app.id
  env_id                 = var.dev_env
}

resource "humanitec_resource_definition" "postgres_dev" {
  driver_type = "humanitec/terraform"
  id          = "${var.app_name}-postgres-dev"
  name        = "${var.app_name}-postgres-dev"
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
          url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          name = "mydb"
          size = "small"
        }
      )
    }
  }

}

resource "humanitec_resource_definition_criteria" "postgres_dev" {
  resource_definition_id = humanitec_resource_definition.postgres_dev.id
  app_id                 = humanitec_application.app.id
  env_id                 = var.dev_env
}


resource "humanitec_resource_definition" "mariadb_dev" {
  driver_type = "humanitec/terraform"
  id          = "${var.app_name}-mariadb-dev"
  name        = "${var.app_name}-mariadb-dev"
  type        = "mariadb"

  driver_inputs = {
    secrets = {
      variables = jsonencode({

      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "terraform-training/mariadb/"
          rev  = "refs/heads/main"
          url  = "https://github.com/Humanitec-DemoOrg/aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          name = "mymariadb"
          size = "small"
        }
      )
    }
  }


}

resource "humanitec_resource_definition_criteria" "mariadb_dev" {
  resource_definition_id = humanitec_resource_definition.mariadb_dev.id
  app_id                 = humanitec_application.app.id
  env_id                 = var.dev_env
}

