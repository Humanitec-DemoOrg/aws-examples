variable "app_name" {}

resource "humanitec_application" "app" {
  id   = var.app_name
  name = var.app_name
}
