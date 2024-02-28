variable "aws_account_id" {
  default = ""
}
variable "db_username" {
  default = ""
}
variable "aws_role" {
  default = ""
}
variable "bucket_prefix" {
  default = ""
}
variable "db_instance_size" {
  default = ""
}
variable "db_username_mariadb" {
  default = ""
}
variable "db_password_mariadb" {
  default = ""
}

variable "environment" {}
variable "app_id" {}


resource "humanitec_resource_definition_criteria" "base-env" {
  resource_definition_id = humanitec_resource_definition.base-env.id
  env_type               = var.environment
  app_id                 = var.app_id
}

resource "humanitec_resource_definition" "base-env" {
  driver_type = "humanitec/template"
  id          = "${var.app_id}-base-env-${var.environment}"
  name        = "${var.app_id}-base-env-${var.environment}"
  type        = "base-env"


  driver_inputs = {
    values = {
      templates = jsonencode({
        init      = ""
        manifests = ""
        outputs   = <<EOL
aws_account_id:    "${var.aws_account_id}"
db_username:       "${var.db_username}"
db_instance_size:  "${var.db_instance_size}"
aws_role:          "${var.aws_role}"
bucket_prefix:     "${var.bucket_prefix}"
db_username_mariadb:  "${var.db_username_mariadb}"
EOL
        cookie    = ""
      })
    }
    secrets = {
      templates = jsonencode({
        outputs = <<EOL
db_password_mariadb: "${var.db_password_mariadb}"
EOL
      })
    }
  }
}
