variable "my_input" {
  default = ""
}

variable "my_secret" {
  default   = ""
  sensitive = true
}

output "my_output" {
  value = var.my_input
}

output "my_secret_output" {
  value     = var.my_secret
  sensitive = true
}
