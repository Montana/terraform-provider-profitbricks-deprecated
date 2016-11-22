provider "profitbricks" {
  timeout = 100
}

//Public lan
resource "profitbricks_lan" "webserver_lan" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  public = true
  name = "public"
}

//Web Server
resource "profitbricks_datacenter" "main" {
  name = "datacenter 01"
  location = "us/las"
  description = "description of the datacenter"
}

resource "profitbricks_server" "webserver" {
  name = "webserver"
  datacenter_id = "${profitbricks_datacenter.main.id}"
  cores = 1
  ram = 1024
  availability_zone = "ZONE_1"
  cpu_family = "AMD_OPTERON"

  volume {
    name = "system"
    image_name = "${var.ubuntu}"
    size = 5
    disk_type = "SSD"
    ssh_key_path = [
      "${var.ssh_keys}"]
    image_password = "test1234"
  }

  nic {
    lan = "${profitbricks_lan.webserver_lan.id}"
    dhcp = true
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
      private_key = "${file("${var.private_key_path}")}"
      user = "root"
      timeout = "4m"
    }
  }
}

resource "profitbricks_nic" "secondary_nic" {
  lan = "${profitbricks_lan.webserver_lan.id}"
  datacenter_id = "${profitbricks_datacenter.main.id}"
  server_id = "${profitbricks_server.webserver.id}"

}
