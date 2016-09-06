variable "ubuntu" {
  description = "Ubuntu Server"
  default = "ubuntu-16.04"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default = "/Users/{your_username}/.ssh/id_rsa"
}
