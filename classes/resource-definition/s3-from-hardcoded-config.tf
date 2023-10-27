# This is not recommended to do, this allows to separate resource definitions from hardcoded config files

resource "humanitec_resource_definition" "hardcoded_config_for_s3" {
  driver_type = "humanitec/echo"
  id          = "hardcoded-config-for-s3"
  name        = "hardcoded-config-for-s3"
  type        = "config"

  driver_inputs = {
    secrets_string = jsonencode({
      "user" : "myuser"
      "password" : "mypassword"
    })
    values_string = jsonencode({
      "bucket" : "myhardcodedbucket"
      "region" : "ca-central-1"
    })
  }

  lifecycle {
    ignore_changes = [
      criteria
    ]
  }
}

resource "humanitec_resource_definition_criteria" "hardcoded_config_for_s3d" {
  resource_definition_id = humanitec_resource_definition.hardcoded_config_for_s3.id
  app_id                 = humanitec_application.app.id
  class                  = "hardcoded-config-for-s3"
}

resource "humanitec_resource_definition" "s3_from_hardcoded_config" {
  driver_type = "humanitec/echo"
  id          = "s3-from-hardcoded-config"
  name        = "s3-from-hardcoded-config"
  type        = "s3"

  driver_inputs = {
    secrets_string = jsonencode({
      "aws_access_key_id" : "$${resources['config.hardcoded-config-for-s3'].outputs.user}"
      "aws_secret_access_key" : "$${resources['config.hardcoded-config-for-s3'].outputs.password}"
    })
    values_string = jsonencode({
      "bucket" : "$${resources['config.hardcoded-config-for-s3'].outputs.bucket}"
      "region" : "$${resources['config.hardcoded-config-for-s3'].outputs.region}"
    })
  }
  lifecycle {
    ignore_changes = [
      criteria
    ]
  }
}

resource "humanitec_resource_definition_criteria" "s3_from_hardcoded_config" {
  resource_definition_id = humanitec_resource_definition.s3_from_hardcoded_config.id
  app_id                 = humanitec_application.app.id
  class                  = "s3-from-hardcoded-config"
}
