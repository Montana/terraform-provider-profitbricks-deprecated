provider "profitbricks" {
  timeout = 100
}

data "profitbricks_location" "test1" {
  name = "karl"
  feature = "SSD"
}

//module "data_center" {
//  source = "./data_center"
//  name = "test_module"
//  location = "${data.profitbricks_location.test1.id}"
//}

module "nginx_server" {
  source = "./nginx_server_module"
  name = "test-nginx"
  image_name = "ubuntu-16.04"
  public_ssh_key_path = "/Users/jasmingacic/.ssh/id_rsa.pub"
  private_ssh_key_path = "/Users/jasmingacic/.ssh/id_rsa"
  location = "us/las"
  disk_size = 50
  ram = 4096
  cores = 4
  disk_type = "SSD"
}