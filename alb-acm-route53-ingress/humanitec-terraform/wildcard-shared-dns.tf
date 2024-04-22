variable "dns_shared_resource_name" {}
variable "dns_shared_domain" {}

resource "humanitec_resource_definition" "dns" {
  id          = var.dns_shared_resource_name
  name        = var.dns_shared_resource_name
  type        = "dns"
  driver_type = "humanitec/dns-wildcard"
  provision = {
    "ingress" = {
      "is_dependent" : false,
      "match_dependents" : false
    }
  }

  driver_inputs = {
    values = {
      "domain" : var.dns_shared_domain,
      "template" : "$${context.app.id}-$${context.env.id}"
    }
  }

}


resource "humanitec_resource_definition_criteria" "dns" {
  resource_definition_id = humanitec_resource_definition.dns.id
  app_id                 = humanitec_application.app.id
  res_id                 = "shared.${var.dns_shared_resource_name}"
}
