variable "name" { }
variable "location" { }

resource "profitbricks_datacenter" "main" {
  name = "${var.name}"
  location = "${var.location}"
}

resource "profitbricks_lan" "lan" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  public = true
  name = "public"
}