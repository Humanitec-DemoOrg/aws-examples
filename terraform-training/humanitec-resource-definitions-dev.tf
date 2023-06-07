resource "humanitec_resource_definition" "s3_dev" {
  driver_type = "${var.humanitec_organization}/terraform"
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

  criteria = [
    {
      app_id = humanitec_application.app.id
      env_id = var.dev_env
    }
  ]

}

resource "humanitec_resource_definition" "postgres_dev" {
  driver_type = "${var.humanitec_organization}/terraform"
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

  criteria = [
    {
      app_id = humanitec_application.app.id
      env_id = var.dev_env
    }
  ]

}

resource "humanitec_resource_definition" "mariadb_dev" {
  driver_type = "${var.humanitec_organization}/terraform"
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

  criteria = [
    {
      app_id = humanitec_application.app.id
      env_id = var.dev_env
    }
  ]

}
