provider "profitbricks" {
  timeout = 100
}

//Public lan
resource "profitbricks_lan" "webserver_lan" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  public        = true
  name          = "public"
}

//IP Block
resource "profitbricks_ipblock" "webserver_ip" {
  location = "${profitbricks_datacenter.main.location}"
  size     = 1
}

//Web Server
resource "profitbricks_datacenter" "main" {
  name        = "datacenter 01"
  location    = "us/las"
  description = "description of the datacenter"
}

resource "profitbricks_server" "webserver" {
  name              = "webserver"
  datacenter_id     = "${profitbricks_datacenter.main.id}"
  cores             = 1
  ram               = 1024
  availability_zone = "ZONE_1"
  cpu_family        = "AMD_OPTERON"

  volume {
    name           = "system"
    image_name     = "${var.ubuntu}"
    size           = 5
    disk_type      = "SSD"
    ssh_key_path   = ["${var.ssh_keys}"]
    availability_zone = "AUTO"
  }

  nic {
    lan             = "${profitbricks_lan.webserver_lan.id}"
    dhcp            = true
    ip              = "${profitbricks_ipblock.webserver_ip.0.ips}"
    firewall_active = true

    firewall {
      protocol         = "TCP"
      name             = "SSH"
      port_range_start = 22
      port_range_end   = 22
    }
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install nginx",
    ]

    # install nginx
    connection {
      type        = "ssh"
      private_key = "${file("${var.private_key_path}")}"
      user        = "root"
      timeout     = "4m"
    }
  }
}

resource "profitbricks_nic" "webserver_nic" {
  datacenter_id   = "${profitbricks_datacenter.main.id}"
  server_id       = "${profitbricks_server.webserver.id}"
  lan             = 2
  dhcp            = true
  firewall_active = true
  nat = false
}

resource "profitbricks_firewall" "webserver_ping" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  server_id     = "${profitbricks_server.webserver.id}"
  nic_id        = "${profitbricks_server.webserver.primary_nic}"
  protocol      = "ICMP"
  name          = "PING"
  icmp_type     = 8
  icmp_code     = 0
}

resource "profitbricks_firewall" "webserver_http" {
  datacenter_id    = "${profitbricks_datacenter.main.id}"
  server_id        = "${profitbricks_server.webserver.id}"
  nic_id           = "${profitbricks_server.webserver.primary_nic}"
  protocol         = "TCP"
  name             = "HTTP"
  port_range_start = 80
  port_range_end   = 80
}

resource "profitbricks_firewall" "webserver_https" {
  datacenter_id    = "${profitbricks_datacenter.main.id}"
  server_id        = "${profitbricks_server.webserver.id}"
  nic_id           = "${profitbricks_server.webserver.primary_nic}"
  protocol         = "TCP"
  name             = "HTTPS"
  port_range_start = 443
  port_range_end   = 443
}

//MongoDB Server
resource "profitbricks_ipblock" "database_ip" {
  location = "${profitbricks_datacenter.main.location}"
  size     = 1
}

resource "profitbricks_server" "database" {
  name              = "mongodb"
  datacenter_id     = "${profitbricks_datacenter.main.id}"
  cores             = 1
  ram               = 1024
  availability_zone = "ZONE_1"
  cpu_family        = "INTEL_XEON"

  volume {
    name           = "system"
    image_name     = "${var.ubuntu}"
    size           = 5
    disk_type      = "HDD"
    ssh_key_path   = ["${var.ssh_keys}"]
    image_password = "test1234"
    availability_zone = "ZONE_1"
  }

  nic {
    lan             = "${profitbricks_lan.webserver_lan.id}"
    dhcp            = true
    ip              = "${profitbricks_ipblock.database_ip.0.ips}"
    firewall_active = true

    firewall {
      protocol         = "TCP"
      name             = "SSH"
      port_range_start = 22
      port_range_end   = 22
    }
  }

  provisioner "remote-exec" {
    inline = [
      "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927",
      "echo \"deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse\" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list",
      "apt-get update",
      "apt-get install -y mongodb-org",
    ]

    connection {
      type        = "ssh"
      private_key = "${file("${var.private_key_path}")}"
      user        = "root"
      timeout     = "4m"
    }
  }
}

resource "profitbricks_firewall" "database_mongodb" {
  datacenter_id    = "${profitbricks_datacenter.main.id}"
  server_id        = "${profitbricks_server.database.id}"
  nic_id           = "${profitbricks_server.database.primary_nic}"
  protocol         = "TCP"
  name             = "MongoDB"
  port_range_start = 27017
  port_range_end   = 27017
}

resource "profitbricks_firewall" "database_ping" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  server_id     = "${profitbricks_server.database.id}"
  nic_id        = "${profitbricks_server.database.primary_nic}"
  protocol      = "ICMP"
  name          = "PING"
  icmp_type     = "8"
  icmp_code     = "0"
}

resource "profitbricks_volume" "database_volume" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  server_id     = "${profitbricks_server.database.id}"
  licence_type  = "OTHER"
  name          = "data"
  size          = 5
  disk_type     = "SSD"
  bus           = "VIRTIO"
}

resource "profitbricks_nic" "database_nic" {
  datacenter_id   = "${profitbricks_datacenter.main.id}"
  server_id       = "${profitbricks_server.database.id}"
  lan             = 2
  dhcp            = true
  firewall_active = true
}

//resource "profitbricks_loadbalancer" "example" {
//  datacenter_id = "${profitbricks_datacenter.example.id}"
//  nic_id = "${profitbricks_nic.example.id}"
//  name = "load balancer name"
//  dhcp = true
//}

