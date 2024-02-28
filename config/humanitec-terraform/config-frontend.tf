resource "humanitec_resource_definition" "config_frontend" {
  driver_type = "humanitec/template"
  id          = "config-frontend"
  name        = "config-frontend"
  type        = "config"


  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = ""
        manifests = ""
        outputs   = <<EOL
region: "us-east-1"
bucket: "myusbucket"
EOL
        cookie    = ""
      }
    })
    secrets_string = jsonencode({
      templates = {
        outputs = <<EOL
user: "myaccesskeyid"
password: "myaccesskeysecret"
EOL
      }
    })
  }
}
