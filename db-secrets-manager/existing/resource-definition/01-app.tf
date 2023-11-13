variable "app" {}

resource "humanitec_application" "app" {
  id   = var.app
  name = var.app
}
