resource "humanitec_resource_definition" "blob" {
  driver_type = "humanitec/terraform"
  id          = "${var.HUMANITEC_APP}-azure-blob-${var.HUMANITEC_ENV}"
  name        = "${var.HUMANITEC_APP}-azure-blob-${var.HUMANITEC_ENV}"
  type        = "azure-blob"

  driver_inputs = {

    secrets_string = jsonencode({
    }),
    values_string = jsonencode(
      {
        append_logs_to_error = true

        script = <<-EOT
                        variable "region" {}
                        variable "bucket" {}

                        output "bucket" {
                          value = var.bucket
                        }
                        output "region" {
                          value = var.region
                        }
                    EOT
        source = {}
        variables = {
          bucket = "some-bucket-${var.HUMANITEC_ENV}"
          region = "us-east-1"
        }
      }
    )
  }

}

resource "humanitec_resource_definition_criteria" "blob" {
  resource_definition_id = humanitec_resource_definition.blob.id
  app_id                 = var.HUMANITEC_APP
  env_type               = var.HUMANITEC_ENV
  class                  = "default"
}
