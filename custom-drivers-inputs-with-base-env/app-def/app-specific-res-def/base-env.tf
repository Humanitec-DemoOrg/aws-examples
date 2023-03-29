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

variable "environment" {}
variable "app_id" {}


resource "humanitec_resource_definition" "base-env" {
  driver_type = "humanitec/template"
  id          = "${var.app_id}-base-env-${var.environment}"
  name        = "${var.app_id}-base-env-${var.environment}"
  type        = "base-env"

  criteria = [
    {
      env_type = var.environment
      app_id   = var.app_id
    }
  ]

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
EOL
        cookie    = ""
      })
    }
    secrets = {
    }
  }
}
