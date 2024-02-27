resource "humanitec_resource_definition" "postgres" {
  driver_type = "humanitec/terraform"
  id          = "${var.HUMANITEC_APP}-postgres-${var.HUMANITEC_ENV}"
  name        = "${var.HUMANITEC_APP}-postgres-${var.HUMANITEC_ENV}"
  type        = "postgres"

  driver_inputs = {

    secrets_string = jsonencode({
    }),
    values_string = jsonencode(
      {
        append_logs_to_error = true

        script = <<-EOT
                        variable "username" {}
                        variable "host" {}

                        output "host" {
                          value = var.username
                        }
                        output "username" {
                          value = var.username
                        }
                    EOT
        source = {}
        variables = {
          host     = "some-postgres-host-${var.HUMANITEC_ENV}.com"
          username = var.HUMANITEC_ENV
        }
      }
    )
  }

}

resource "humanitec_resource_definition_criteria" "postgres" {
  resource_definition_id = humanitec_resource_definition.postgres.id
  app_id                 = var.HUMANITEC_APP
  env_type               = var.HUMANITEC_ENV
  class                  = "default"
}
