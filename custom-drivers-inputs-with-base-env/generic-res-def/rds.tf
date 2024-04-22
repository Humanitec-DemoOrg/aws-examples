resource "humanitec_resource_definition" "postgres" {
  driver_type = "humanitec/terraform"
  id          = "generic-res-postgres"
  name        = "generic-res-postgres"
  type        = "postgres"

  driver_inputs = {
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
          username = "$${resources.base-env.outputs.db_username}"
          size     = "$${resources.base-env.outputs.db_instance_size}"
        }
      )
    }
  }


}

resource "humanitec_resource_definition_criteria" "postgres" {
  resource_definition_id = humanitec_resource_definition.postgres.id
  app_id                 = var.app_id
}
