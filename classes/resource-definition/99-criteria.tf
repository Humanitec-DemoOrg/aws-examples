resource "humanitec_resource_definition_criteria" "s3_sse" {
  resource_definition_id = humanitec_resource_definition.s3_sse.id
  app_id                 = humanitec_application.app.id
  class                  = "sse"
}

resource "humanitec_resource_definition_criteria" "s3_kms" {
  resource_definition_id = humanitec_resource_definition.s3_kms.id
  app_id                 = humanitec_application.app.id
  class                  = "kms"
}

