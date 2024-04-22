variable "dns_local_resource_name" {}
variable "dns_local_domain" {}

resource "humanitec_resource_definition" "dns_local" {
  id          = var.dns_local_resource_name
  name        = var.dns_local_resource_name
  type        = "dns"
  driver_type = "humanitec/template"

  provision = {
    "ingress" = {
      "is_dependent" : false,
      "match_dependents" : false
    }
  }

  driver_inputs = {
    values_string = jsonencode({

      templates = {
        init      = <<EOL
D: ".${var.dns_local_domain}"
W: {{ index (regexSplit "\\." "$${context.res.id}" -1) 1 }}
EOL
        manifests = ""
        outputs   = <<EOL
host: $${context.app.id}-{{.init.W}}-$${context.env.id}{{.init.D}}
EOL
        cookie    = ""
      }
    })
  }

}

resource "humanitec_resource_definition_criteria" "dns_local1" {
  resource_definition_id = humanitec_resource_definition.dns_local.id
  app_id                 = humanitec_application.app.id
  res_id                 = "modules.backend.externals.${var.dns_local_resource_name}"
}

resource "humanitec_resource_definition_criteria" "dns_local2" {
  resource_definition_id = humanitec_resource_definition.dns_local.id
  app_id                 = humanitec_application.app.id
  res_id                 = "modules.frontend.externals.${var.dns_local_resource_name}"
}
