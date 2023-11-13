variable "postgres_master_secret" {}
variable "new_db_name" {}
variable "new_db_user" {}
variable "new_db_secret" {}

resource "random_string" "password" {
  length  = 32
  special = false
  lower   = true
}

//connect to existing RDS instance(or create a new one and return the credentials)
//replace this with your own RDS module to create your own instance

data "aws_secretsmanager_secret" "postgres_password" {
  name = var.postgres_master_secret
}
data "aws_secretsmanager_secret_version" "postgres_password" {
  secret_id = data.aws_secretsmanager_secret.postgres_password.id
}

provider "postgresql" {
  host      = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string).endpoint
  database  = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string).database
  username  = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string).username
  password  = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string).password
  port      = 5432
  superuser = false
}

//once you connect to your server (or create one), then proceed to create users and schemas and manage the database with your own tools

resource "postgresql_database" "db" {
  name = var.new_db_name // make sure to sanitize your db name
}

resource "postgresql_role" "user" {
  name     = var.new_db_user // make sure to sanitize your db user
  login    = true
  password = random_string.password.result
  lifecycle {
    ignore_changes = [
      roles,
    ]
  }
}

resource "postgresql_grant_role" "admin" {
  role       = var.new_db_user // make sure to sanitize your db user
  grant_role = "rds_superuser" // adjust roles accordingly
}

resource "aws_secretsmanager_secret" "secret" {
  name = var.new_db_secret // make sure to sanitize your db secret
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    "endpoint" : jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string).endpoint,
    "password" : random_string.password.result,
    "username" : var.new_db_user,
    "database" : var.new_db_name
    }
  )
}

# https://developer.humanitec.com/platform-orchestrator/reference/resource-types/#postgres
output "host" {
  value = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string).endpoint
}
output "name" {
  value = var.new_db_name
}
output "port" {
  value = "5432"
}
output "username" {
  value     = var.new_db_user
  sensitive = true
}
output "password" {
  value     = random_string.password.result
  sensitive = true
}
