variable "app_id" {}

resource "humanitec_application" "app" {
  id   = var.app_id
  name = var.app_id
}
