variable "extensions" {
  default = ""
}

variable "host" {
  default = "db.example.com"
}

variable "name" {
  default = "sakilladb"
}

variable "password" {
  sensitive = true
  default   = "verysecret"
}

variable "port" {
  default = 3306
}

variable "username" {
  default = "user"
}

output "host" {
  value = var.host
}

output "name" {
  value = var.name
}

output "password" {
  sensitive = true
  value     = var.password
}

output "port" {
  value = var.port
}

output "username" {
  value = var.username
}
