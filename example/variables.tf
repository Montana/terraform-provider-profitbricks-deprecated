variable "ubuntu" {
  description = "Ubuntu Server"
  default     = "ubuntu-16.04"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default     = "/Users/{your_username}/.ssh/id_rsa"
}

variable "ssh_keys" {
  description = "List of SSH Keys to be added to the VMs"

  default = ["/home/{your_username}/.ssh/your_public_key",
    "/home/ANOTHER-USER/.ssh/another_public_key",
  ]
}
