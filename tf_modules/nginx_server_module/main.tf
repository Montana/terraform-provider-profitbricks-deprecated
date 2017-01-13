variable "name" {
}
variable "image_name" {
}
variable "location" {
}
variable "public_ssh_key_path" {
}
variable "private_ssh_key_path" {
}
variable "disk_size" {
}variable "disk_type" {
}
variable "cores" {
}
variable "ram" {
}

resource "profitbricks_datacenter" "main" {
  name = "${var.name}"
  location = "${var.location}"
}

data "profitbricks_image" "test_img" {
  name = "${var.image_name}"
  type = "HDD"
  location = "${var.location}"
}

resource "profitbricks_ipblock" "webserver_ip" {
  location = "${var.location}"
  size = 1
}

resource "profitbricks_lan" "lan" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  public = true
  name = "public"
}


resource "profitbricks_server" "webserver" {
  name = "${var.name}"
  datacenter_id = "${profitbricks_datacenter.main.id}"
  cores = "${var.cores}"
  ram = "${var.ram}"

  volume {
    name = "system"
    image_name = "${data.profitbricks_image.test_img.id}"
    size = "${var.disk_size}"
    disk_type = "${var.disk_type}"
    ssh_key_path = [
      "${var.public_ssh_key_path}"]
  }

  nic {
    lan = "${profitbricks_lan.lan.id}"
    dhcp = true
    ip = "${profitbricks_ipblock.webserver_ip.0.ips}"
    firewall_active = true

    firewall {
      protocol = "TCP"
      name = "SSH"
      port_range_start = 22
      port_range_end = 22
    }
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install nginx",
    ]

    # install nginx
    connection {
      type = "ssh"
      private_key = "${file("${var.private_ssh_key_path}")}"
      user = "root"
      timeout = "4m"
    }
  }
}