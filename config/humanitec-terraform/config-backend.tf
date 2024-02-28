resource "humanitec_resource_definition" "config_backend" {
  driver_type = "humanitec/echo"
  id          = "config-backend"
  name        = "config-backend"
  type        = "config"

  driver_inputs = {
    secrets_string = jsonencode({
      "user" : "myuser"
      "password" : "mypassword"
    })
    values_string = jsonencode({
      "bucket" : "mybucket"
      "region" : "ca-central-1"
    })
  }

}
