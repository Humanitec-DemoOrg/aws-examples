resource "humanitec_resource_definition" "mariadb" {
  driver_type = "humanitec/terraform"
  id          = "generic-res-mariadb"
  name        = "generic-res-mariadb"
  type        = "mariadb"

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        password = "$${resources.base-env.outputs.db_password_mariadb}"
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
          username = "$${resources.base-env.outputs.db_username_mariadb}"
        }
      )
    }
  }


}


resource "humanitec_resource_definition_criteria" "mariadb" {
  resource_definition_id = humanitec_resource_definition.mariadb.id
  app_id                 = var.app_id
}
