resource "humanitec_resource_definition_criteria" "s3" {
  resource_definition_id = humanitec_resource_definition.s3.id
  app_id                 = humanitec_application.app.id
}

resource "humanitec_resource_definition_criteria" "s3_backend" {
  resource_definition_id = humanitec_resource_definition.config_backend.id
  res_id                 = "modules.backend.externals.mys3"
}

resource "humanitec_resource_definition_criteria" "s3_frontend" {
  resource_definition_id = humanitec_resource_definition.config_frontend.id
  res_id                 = "modules.frontend.externals.mys3"
}
