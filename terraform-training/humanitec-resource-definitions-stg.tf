resource "humanitec_resource_definition" "s3_stg" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-s3-stg"
  name        = "${var.app_name}-s3-stg"
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
      env_id = var.stg_env
    }
  ]

}

resource "humanitec_resource_definition" "postgres_stg" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-postgres-stg"
  name        = "${var.app_name}-postgres-stg"
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
          size = "xl"
        }
      )
    }
  }

  criteria = [
    {
      app_id = humanitec_application.app.id
      env_id = var.stg_env
    }
  ]

}

resource "humanitec_resource_definition" "mariadb_stg" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-mariadb-stg"
  name        = "${var.app_name}-mariadb-stg"
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
          size = "xl"
        }
      )
    }
  }

  criteria = [
    {
      app_id = humanitec_application.app.id
      env_id = var.stg_env
    }
  ]

}
