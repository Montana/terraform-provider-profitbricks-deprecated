# Terraform ProfitBricks Provider

* [Introduction](#introduction)
* [Installation](#installation)
* [Download Plugin Binaries](#download-plugin-binaries)
  * [Build Plugin from Source](#build-plugin-from-source)
* [Plugin Usage](#plugin-usage)
  * [Credentials](#credentials)
  * [Basic Example](#basic-example)
  * [Complex Example](#complex-example)
* [ProfitBricks Resources](#profitbricks-resources)
  * [Virtual Data Center](#virtual-data-center)
  * [Server](#server)
  * [Volume](#volume)
  * [NIC](#nic)
  * [IP Block](#ip-block)
  * [LAN](#lan)
  * [Firewall Rule](#firewall-rule)
  * [Load Balancer](#load-balancer)
* [ProfitBricks Data Sources](#profitbricks-data-sources)
  * [Data Centers Data Source](#data-centers-data-source)
  * [Images Data Source](#images-data-source)
  * [Locations Data Source](#locations-data-source)
* [Support](#support)

## Introduction

The ProfitBricks provider for Terraform is used to interact with the cloud computing and storage resources provided by ProfitBricks. Before you begin you will need to have [signed up for a ProfitBricks account](https://www.profitbricks.com/signup). The credentials you create during sign-up will be used to authenticate against the Cloud API.

## Installation

Terraform must first be installed on your local machine or wherever you plan to run it from. Terraform is distributed as a [binary package](https://www.terraform.io/downloads.html) for various platforms and architectures.

To install Terraform, find the appropriate package for your system and download it. Terraform is packaged as a zip archive.

After downloading, unzip the package into a directory where Terraform will be installed. (Example: `~/terraform` or `c:\terraform`)

The final installation step is to make sure the directory you installed Terraform into is included in the *PATH*.

If you plan to run `terraform` in a shell on Linux and placed the binary in `/home/YOUR-USER-NAME/terraform/` then type the following into your terminal:

```bash
PATH=$PATH:/home/[YOUR-USER-NAME]/terraform
```

You can view the current value of *$PATH* by running:

```bash
echo $PATH
```

If you plan to run `terraform` in a shell on a Mac and placed the binary in `/Users/YOUR-USER-NAME/terraform/` then type the following into your terminal:

```bash
PATH=$PATH:/Users/[YOUR-USER-NAME]/terraform
```

You can view the current value of *$PATH* by running:

```bash
echo $PATH
```

If you plan to run `terraform.exe` in PowerShell on Windows and placed the binary in `c:\terraform` then type the following into PowerShell:

First look at the existing value of *PATH*:

```powershell
echo $env:Path
```

If it ends with a **;**, then run:

```powershell
$env:Path += "c:\terraform"
```

If it does **NOT** end with a **;**, then run:

```powershell
$env:Path += ";c:\terraform"
```

The adjustments to the *PATH* environment variable as outlined above are *temporary*. There are numerous examples available on the internet describing how to make permanent changes to environment variables for each particular operating system. The [Terraform Installation instructions](https://www.terraform.io/intro/getting-started/install.html) link to a couple examples.

If you do not want to mess around with changing the *PATH* at all, it is usually possible to execute items in a particular directory by entering `./terraform` or providing a full path such as: `c:\terraform\terraform.exe`.

After installing Terraform, verify the installation by executing `terraform` or `terraform.exe`. You  should see the default "usage" output similar to this:

```bash
$ terraform
usage: terraform [--version] [--help] <command> [<args>]

Available commands are:
    apply       Builds or changes infrastructure
    destroy     Destroy Terraform-managed infrastructure
    get         Download and install modules for the configuration
    graph       Create a visual graph of Terraform resources
    init        Initializes Terraform configuration from a module
    output      Read an output from a state file
    plan        Generate and show an execution plan
    push        Upload this Terraform module to Atlas to run
    refresh     Update local state file against real resources
    remote      Configure remote state storage
    show        Inspect Terraform state or plan
    taint       Manually mark a resource for recreation
    validate    Validates the Terraform files
    version     Prints the Terraform version
```

## Download Plugin Binaries

Download the desired release archive from [ProfitBricks Terraform Provider Releases](https://github.com/profitbricks/terraform-provider-profitbricks/releases). Extract the binary from the archive and place it in the same location you used for the Terraform binary in the previous step. It should have the name `terraform-provider-profitbricks` or `terraform-provider-profitbricks.exe`

The binary should be available in the *PATH* if you made the changes to that environment variable as described above.

### Build Plugin from Source

This is an optional step. We recommend you utilize the binary releases whenever possible. However, if you would like to build the provider plugin yourself, here is an overview of the necessary steps:

The build process requires that the [GO](https://golang.org/) language be installed and configured on your system. Getting `go` setup is fairly straight-forward but please pay attention to the [installation instructions](https://golang.org/doc/install) relevant to your operating system.

Once you have GO installed and working, then retrieve the Terraform ProfitBricks provider project source code by executing the following command:

```
go get github.com/profitbricks/terraform-provider-profitbricks
```

Then change to the project directory and run `make install`:

```
cd $GOPATH/github.com/profitbricks/terraform-provider-profitbricks

make install
```

The resulting binary can be copied to the same directory you installed Terraform in, or another appropriate location included in the *PATH*.

## Plugin Usage

We will go through a basic example of provisioning a server inside a Virtual Data Center after providing Terraform with our credentials.

### Credentials

You can provide your credentials using the `PROFITBRICKS_USERNAME` and `PROFITBRICKS_PASSWORD`
environment variables, representing your ProfitBricks username and password, respectively.

```
$ export PROFITBRICKS_USERNAME="profitbricks_username"
$ export PROFITBRICKS_PASSWORD="profitbricks_password"
```

Or you can include your credentials inside the `main.tf` file like this:

```
provider "profitbricks" {
    username = "profitbricks_username"
    password = "profitbricks_password"
    timeout = 100
}
```

Timeout describes the number of retries while waiting for a resource to be provisioned. The default value is 50.

### Basic Example

In this example we will create a Virtual Data Center with an Ubuntu server:

First create a configuration directory:

```
mkdir ~/terraform
```

Change your current directory to the newly created directory:

```
cd ~/terraform
```

Create the text file `main.tf`. Terraform utilizes files with the extension `.tf` for configuration. **Please Note:** ALL files with the extension `.tf` **WILL** be parsed when running `terraform`, so don't use that extension for files that you don't want it to see.

In a Linux or Mac shell you might utilize `vi`, but any text editor should suffice.

```
vi main.tf
```

Copy following into `main.tf`:

```
// Credentials (unless you are using environment variables for these)
provider "profitbricks" {
  username = "profitbricks_username"
  password = "profitbricks_password"
  timeout = 100
}

//Virtual Data Center
resource "profitbricks_datacenter" "main" {
  name = "datacenter 01"
  location = "us/las"
  description = "Description of the Virtual Data Center"
}

//Public lan
resource "profitbricks_lan" "webserver_lan" {
  datacenter_id = "${profitbricks_datacenter.main.id}"
  public = true
  name = "public"
}

//IP Block
resource "profitbricks_ipblock" "webserver_ip" {
  location = "${profitbricks_datacenter.main.location}"
  size = 1
}

//Web server
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
    size = 15
    disk_type = "HDD"
    ssh_key_path = ["${var.ssh_keys}"]
    image_password = "test1234"
  }
  nic {
    lan = "${profitbricks_lan.webserver_lan.id}"
    dhcp = true
    ip = "${profitbricks_ipblock.webserver_ip.ips}"
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
      # install nginx
      "apt-get update",
      "apt-get -y install nginx"
    ]
    connection {
      type = "ssh"
      private_key = "${file("${var.private_key_path}")}"
      user = "root"
      timeout = "4m"
    }
  }
}
```

Create the `variables.tf` text file and add these lines to specify Ubuntu 16.04 as the provisioned OS and add one or more public keys that you want to be added to the provisioned VM:

```
variable "ubuntu" {
  description = "Ubuntu Server"
  default = "ubuntu-16.04"
}

variable "ssh_keys" {
  description = "List of SSH Keys to be added to the VMs"
  default = ["/home/YOUR-USER-NAME/.ssh/your_public_key",
    "/home/ANOTHER-USER/.ssh/another_public_key",
  ]
}
```

We are already setting a password of `test1234` in the `main.tf` file, but we can pass public SSH key(s) to the build process by placing it in a file and including it in the configuration. This will add the public SSH key(s) to the `/root/.ssh/authorized_keys` file allowing us to connect using our private SSH key instead of a password. This will **ONLY** work with any of the Linux images provided by ProfitBricks. Once you have your private SSH key saved in `/home/YOUR-USER-NAME/my_private_key `, then add these lines to `variables.tf`:

```
variable "private_key_path" {
  description = "Path to file containing private key"
  default = "/home/YOUR-USER-NAME/.ssh/my_private_key"
}
```

If you do not want to provide one or more public SSH key(s), then remove the line:

```
ssh_key_path = ["${var.ssh_keys}"]
```

from `main.tf`. Also alter the `provisioner` section that installs `nginx` so it uses a `password` instead of a `private_key` for authentication:

```
provisioner "remote-exec" {
    inline = [
      # install nginx
      "apt-get update",
      "apt-get -y install nginx"
    ]
    connection {
      type = "ssh"
      password = "test1234"
      user = "root"
      timeout = "4m"
    }
  }
```

otherwise `terraform plan` will generate an error similar to this:

```
Error configuring: 2 error(s) occurred:

* profitbricks_server.webserver: missing dependency: var.private_key_path
* profitbricks_server.webserver: missing dependency: var.private_key_path
```

Now we run `terraform` with the `plan` parameter to review the execution plan:

```
$ terraform plan

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.


The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

+ profitbricks_datacenter.main
    description: "description of the datacenter"
    location:    "us/las"
    name:        "datacenter 01"

+ profitbricks_ipblock.webserver_ip
    ips:      "<computed>"
    location: "us/las"
    size:     "1"

+ profitbricks_lan.webserver_lan
    datacenter_id: "${profitbricks_datacenter.main.id}"
    name:          "public"
    public:        "true"

+ profitbricks_server.webserver
    availability_zone:                                   "ZONE_1"
    boot_cdrom:                                           "<computed>"
    boot_image:                                           "<computed>"
    boot_volume:                                          "<computed>"
    cores:                                               "1"
    cpu_family:                                          "AMD_OPTERON"
    datacenter_id:                                       "${profitbricks_datacenter.main.id}"
    name:                                                "webserver"
    nic.#:                                               "1"
    nic.~3990006432.dhcp:                                "true"
    nic.~3990006432.firewall.#:                          "1"
    nic.~3990006432.firewall.506939247.icmp_code:        ""
    nic.~3990006432.firewall.506939247.icmp_type:        ""
    nic.~3990006432.firewall.506939247.ip:               ""
    nic.~3990006432.firewall.506939247.name:             "SSH"
    nic.~3990006432.firewall.506939247.port_range_end:   "22"
    nic.~3990006432.firewall.506939247.port_range_start: "22"
    nic.~3990006432.firewall.506939247.protocol:         "TCP"
    nic.~3990006432.firewall.506939247.source_ip:        ""
    nic.~3990006432.firewall.506939247.source_mac:       ""
    nic.~3990006432.firewall.506939247.target_ip:        ""
    nic.~3990006432.firewall_active:                     "true"
    nic.~3990006432.ip:                                  "${profitbricks_ipblock.webserver_ip.ips}"
    nic.~3990006432.lan:                                 "0"
    nic.~3990006432.name:                                ""
    primary_nic:                                         "<computed>"
    ram:                                                 "1024"
    volume.#:                                            "1"
    volume.2973529261.bus:                               ""
    volume.2973529261.cpuHotPlug:                        "<computed>"
    volume.2973529261.cpuHotUnplug:                      "<computed>"
    volume.2973529261.discScsiHotPlug:                   "<computed>"
    volume.2973529261.discScsiHotUnplug:                 "<computed>"
    volume.2973529261.discVirtioHotPlug:                 "<computed>"
    volume.2973529261.discVirtioHotUnplug:               "<computed>"
    volume.2973529261.disk_type:                         "HDD"
    volume.2973529261.image_password:                    "test1234"
    volume.2973529261.licence_type:                      ""
    volume.2973529261.name:                              "system"
    volume.2973529261.nicHotPlug:                        "<computed>"
    volume.2973529261.nicHotUnplug:                      "<computed>"
    volume.2973529261.ramHotPlug:                        "<computed>"
    volume.2973529261.ramHotUnplug:                      "<computed>"
    volume.2973529261.size:                              "15"
    volume.2973529261.ssh_key_path.#:                    "2"
    volume.2973529261.ssh_key_path.0:                    "/home/YOUR-USER-NAME/.ssh/your_public_key"
    volume.2973529261.ssh_key_path.1:                    "/home/ANOTHER-USER/.ssh/another_public_key"
```

After you have reviewed the `terraform plan` output, proceed to build the infrastructure by running:

```
terraform apply
```

You should see output similar to this: (truncated)

```
profitbricks_datacenter.main: Creating...
  description: "" => "Description of the Virtual Data Center"
  location:    "" => "us/las"
  name:        "" => "datacenter 01"
profitbricks_datacenter.main: Creation complete
profitbricks_ipblock.webserver_ip: Creating...
  ips:      "" => "<computed>"
  location: "" => "us/las"
  size:     "" => "1"
profitbricks_lan.webserver_lan: Creating...
  datacenter_id: "" => "f40a859f-f110-41ad-9adf-49a42a25db91"
  name:          "" => "public"
  public:        "" => "true"
profitbricks_ipblock.webserver_ip: Creation complete
profitbricks_lan.webserver_lan: Still creating... (10s elapsed)
profitbricks_lan.webserver_lan: Creation complete
profitbricks_server.webserver: Creating...
  availability_zone:                                  "" => "ZONE_1"
  boot_cdrom:                                          "" => "<computed>"
  boot_image:                                          "" => "<computed>"
  boot_volume:                                         "" => "<computed>"
  cores:                                              "" => "1"
  cpu_family:                                         "" => "AMD_OPTERON"
  datacenter_id:                                      "" => "f40a859f-f110-41ad-9adf-49a42a25db91"
  name:                                               "" => "webserver"
  nic.#:                                              "0" => "1"
  nic.2035999756.dhcp:                                "" => "true"
  nic.2035999756.firewall.#:                          "0" => "1"
  nic.2035999756.firewall.506939247.icmp_code:        "" => ""
  nic.2035999756.firewall.506939247.icmp_type:        "" => ""
  nic.2035999756.firewall.506939247.ip:               "" => ""
  nic.2035999756.firewall.506939247.name:             "" => "SSH"
  nic.2035999756.firewall.506939247.port_range_end:   "" => "22"
  nic.2035999756.firewall.506939247.port_range_start: "" => "22"
  nic.2035999756.firewall.506939247.protocol:         "" => "TCP"
  nic.2035999756.firewall.506939247.source_ip:        "" => ""
  nic.2035999756.firewall.506939247.source_mac:       "" => ""
  nic.2035999756.firewall.506939247.target_ip:        "" => ""
  nic.2035999756.firewall_active:                     "" => "true"
  nic.2035999756.ip:                                  "" => "158.222.103.176"
  nic.2035999756.lan:                                 "" => "1"
  nic.2035999756.name:                                "" => ""
  primary_nic:                                        "" => "<computed>"
  ram:                                                "" => "1024"
  volume.#:                                           "0" => "1"
  volume.2973529261.bus:                              "" => ""
  volume.2973529261.cpuHotPlug:                       "" => "<computed>"
  volume.2973529261.cpuHotUnplug:                     "" => "<computed>"
  volume.2973529261.discScsiHotPlug:                  "" => "<computed>"
  volume.2973529261.discScsiHotUnplug:                "" => "<computed>"
  volume.2973529261.discVirtioHotPlug:                "" => "<computed>"
  volume.2973529261.discVirtioHotUnplug:              "" => "<computed>"
  volume.2973529261.disk_type:                        "" => "HDD"
  volume.2973529261.image_password:                   "" => "test1234"
  volume.2973529261.licence_type:                     "" => ""
  volume.2973529261.name:                             "" => "system"
  volume.2973529261.nicHotPlug:                       "" => "<computed>"
  volume.2973529261.nicHotUnplug:                     "" => "<computed>"
  volume.2973529261.ramHotPlug:                       "" => "<computed>"
  volume.2973529261.ramHotUnplug:                     "" => "<computed>"
  volume.2973529261.size:                             "" => "15"
  volume.2973529261.ssh_key_path.#:                   "2"
  volume.2973529261.ssh_key_path.0:                   "/home/YOUR-USER-NAME/.ssh/your_public_key"
  volume.2973529261.ssh_key_path.1:                   "/home/ANOTHER-USER/.ssh/another_public_key"
  ...
  ...
  Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

If you happen to get stuck, and Terraform is not working as you expect, you can start over by deleting the `terraform.tfstate` file, and manually destroying any resources that were provisioned. This can be done quickly using the [ProfitBricks Data Center Designer (DCD)](https://my.profitbricks.com) or by making calls to the Cloud API using `curl` or another tool for interacting with a REST-based API.

If you want to have detailed "DEBUG" information included in Terraform's output, you can set the `TF_LOG` environment variable.

From a shell on Linux or Mac, this can be done using `export`:

```
export TF_LOG=1
```

In PowerShell on Windows:

```
$env:TF_LOG = 1
```

and then verify it was set:

```
echo $env:TF_LOG
1
```

If you wish to **update** one of the resources in the `main.tf`, just edit `main.tf` and make changes to the specific resource. For example, to rename the Virtual Data Center:

```
//Virtual Data Center
resource "profitbricks_datacenter" "main" {
  name = "datacenterrename"
  location = "us/las"
  description = "Description of the Virtual Data Center"
}
...
```

After you are done with editing run this:

```
terraform plan

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.

profitbricks_datacenter.main: Refreshing state... (ID: f40a859f-f110-41ad-9adf-49a42a25db91)
profitbricks_ipblock.webserver_ip: Refreshing state... (ID: 7d0746c7-7985-4050-8770-5c39197e179d)
profitbricks_lan.webserver_lan: Refreshing state... (ID: 1)
profitbricks_server.webserver: Refreshing state... (ID: 82100380-3ecb-4bfd-9cd7-01bd4f2d8127)

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

~ profitbricks_datacenter.main
    name: "datacenter 01" => "datacenterrename"

```

Terraform will inform you about the changes that will happen once you run `terraform apply`. If you are satisfied with the summarized changes, then run `terraform apply`.

To **remove** the infrastructure you used Terraform to create, run:

```
$ terraform destroy

Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

This will remove the entire infrastructure defined in `main.tf`.

For a more complex example see the [Complex Example](#complex-example) section below.

### Complex Example

You can get a working example [from the Github project repository](https://github.com/ProfitBricks/terraform-provider-profitbricks/tree/master/example). Download the two files, `main.tf` and `variables.tf`, place them on the system running Terraform. Then personalize the files contents to your liking.

Next run:

```
terraform plan
```

Review the output and then apply the configuration by running:

```
terraform apply
```

The example files will create a Virtual Data Center with a web server (Nginx) and database server (MongoDB).

Terraform will guide you through the rest of the process.

## ProfitBricks Resources

This section describes the various ProfitBricks resource types that can be deployed using this Terraform provider.

### Virtual Data Center

A Virtual Data Center (VDC) contains all the compute, storage, and networking resources you deploy at ProfitBricks. Therefore, you need to provision a VDC, or provide Terraform with the UUID of an existing one created using the DCD or API.

#### Example Syntax

```
resource "profitbricks_datacenter" "example" {
  name = "datacenter name"
  location = "us/las"
  description = "Virtual Data Center description"
}
```

#### Argument Reference

The following arguments are supported:

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the Virtual Data Center. |
| location | Yes | string |  The physical location where the Virtual Data Center will be created. ["us/las", "de/fra", or "de/fkb"] |
| description | No | string | A description of the Virtual Data Center. |

### Server

This is used to provision a server with associated resources such as processor cores, memory, a primary storage volume, and a network interface.

#### Example Syntax

```
resource "profitbricks_server" "example" {
     name = "server"
     datacenter_id = "${profitbricks_datacenter.example.id}"
     cores = 1
     ram = 1024
     availability_zone = "ZONE_1"
     cpu_family = "AMD_OPTERON"
     volume {
       name = "new"
       image_name = "${var.ubuntu}"
       size = 5
       disk_type = "SSD"
       ssh_key_path = "${var.private_key_path}"
       image_password = "test1234"
     }
     nic {
       lan = "${profitbricks_lan.example.id}"
       dhcp = true
       ip = "${profitbricks_ipblock.example.ip}"
       firewall_active = true
       firewall {
         protocol = "TCP"
         name = "SSH"
         port_range_start = 22
         port_range_end = 22
       }
     }
   }
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the server. |
| datacenter_id | Yes* | string | The UUID of the Virtual Data Center the server resource is associated with. Terraform will determine this automatically if you are creating the VDC and server at the same time. |
| cores| Yes | integer |  The number of processor cores assigned to this server. |
| ram | Yes | integer | The amount of memory assigned to this server in MB. Should be multiples of 256. |
| availability_zone | No | string | The compute resource availability zone. ["AUTO", "ZONE_1", or "ZONE_2"] |
| licence_type | No | string | Sets the OS type of the server. ["LINUX", "WINDOWS", or "OTHER"] |
| cpuFamily | No | string | Sets the CPU type. ["AMD_OPTERON" or "INTEL_XEON"] |
| volume | Yes | | See Volume section. |
| nic | Yes | | See NIC section. |
| firewall | No | | See Firewall Rule section. |

\* See the *Description* column for details.

### Volume

A primary volume will be created with the server. If there is a need for additional volumes, this resource handles it.

#### Example Syntax

```
resource "profitbricks_volume" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  server_id = "${profitbricks_server.example.id}"
  image_name = "${var.ubuntu}"
  size = 5
  disk_type = "HDD"
  sshkey_path = "${var.private_key_path}"
  bus = "VIRTIO"
  availablity_zone = "ZONE_1"
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| datacenter_id | Yes* | string | UUID of an existing Virtual Data Center resource. This parameters is not required if used under Server resource. |
| server_id | Yes* | string | UUID of an existing server resource. This parameters is not required if used under Server resource. |
| disk_type | Yes | string | The storage volume type. ["HDD", or "SSD"] |
| bus | Yes | string | The bus type of the storage volume. ["VIRTIO", or "IDE"] |
| size |  Yes | integer | The size of the storage volume in GB. |
| image_password | Yes* | string | Password set for the `root` or `Administrator` user on ProfitBricks provided images. Required if `sshkey_path` is not provided. |
| sshkey_path | Yes* | string | Path to a file containing a public SSH key that will be injected into ProfitBricks provided Linux images. Required if `image_password` is not provided. |
| image_name | Yes* | string | The image or snapshot UUID. It is required if `licence_type` is not provided. |
| licence_type | Yes* |string | Required if `image_name` is not provided. ["LINUX", "WINDOWS", or "OTHER"] |
| name | No | string | A name for the storage volume. |
| availability_zone | No | string | Availability Zone for the storage. ["AUTO", "ZONE_1", "ZONE_2"] |

\* See the *Description* column for details.

### NIC

#### Example Syntax

```
resource "profitbricks_nic" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  server_id = "${profitbricks_server.example.id}"
  lan = 2
  dhcp = true
  ip = "${profitbricks_ipblock.example.ip}"
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| datacenter_id | Yes* | string | UUID of an existing Virtual Data Center resource. This parameters is not required if used under Server resource. |
| server_id | Yes*  | string | UUID of an existing server resource. This parameters is not required if used under Server resource. |
| lan | Yes | integer | The LAN ID the NIC will sit on. |
| name| No | string |  The name of the LAN. |
| dhcp| No| boolean | If the NIC should get an IP using DHCP. |
| ip | No | string | IPs assigned to the NIC. Value to be passed in form of a comma separated string "192.168.1.1,192.168.1.2" |
| firewall_active | No | boolean | If this resource is set to `true` and is nested under a server resource firewall, with open SSH port, resource must be nested under the NIC. |
| nat | No | boolean | Network Address Translation |

\* See the *Description* column for details.

### IP Block

#### Example Syntax

```
resource "profitbricks_ipblock" "example" {
  location = "${profitbricks_datacenter.example.location}"
  size = 1
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| location | Yes | string |  The physical location where the Virtual Data Center will be created. ["us/las", "de/fra", or "de/fkb"] |
| size | Yes | integer | The number of IP addresses reserved in the IP Block. |


### LAN

#### Example Syntax

```
resource "profitbricks_lan" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  public = true
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| datacenter_id | Yes* | string | UUID of an existing Virtual Data Center resource. This parameters is not required if used under Server resource. |
| name | No | string | The name of the LAN |
| public | No | boolean | Indicates if the LAN faces the public Internet or is "private". |

\* See the *Description* column for details.

**Please Note:** Due to a known issue with ProfitBricks Cloud API, the Terraform ProfitBricks Provider does not currently support creating multiple LAN objects. This should be resolved in the near future.

### Firewall Rule

#### Example Syntax

```
resource "profitbricks_firewall" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  server_id = "${profitbricks_server.example.id}"
  nic_id = "${profitbricks_server.example.primary_nic}"
  protocol = "TCP"
  name = "test"
  port_range_start = 1
  port_range_end = 2
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| datacenter_id | Yes* | string | UUID of an existing Virtual Data Center resource. This parameters is not required if used under Server resource. |
| server_id | Yes*  | string | UUID of an existing server resource. This parameters is not required if used under Server resource. |
| nic_id | Yes*  | string | UUID of an existing server resource. This parameters is not required if used under Server resource. |
| protocol | Yes | string | The protocol for the rule: TCP, UDP, ICMP, ANY. |
| name | No | string | The name of the firewall rule. |
| source_mac | No | string | Only traffic originating from the respective MAC address is allowed. Valid format: aa:bb:cc:dd:ee:ff. |
| source_ip | No | string | Only traffic originating from the respective IPv4 address is allowed. |
| target_ip | No | string | Only traffic directed to the respective IP address of the NIC is allowed. |
| port_range_start | No  | string | Defines the start range of the allowed port (from 1 to 65534) if protocol TCP or UDP is chosen. |
| port_range_end | No | string | Defines the end range of the allowed port (from 1 to 65534) if the protocol TCP or UDP is chosen. |
| icmp_type | No | string | Defines the allowed type (from 0 to 254) if the protocol ICMP is chosen. |
| icmp_code | No | string | Defines the allowed code (from 0 to 254) if protocol ICMP is chosen. |

\* See the *Description* column for details.

### Load Balancer

#### Example Syntax

```
resource "profitbricks_loadbalancer" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  nic_id = "${profitbricks_nic.example.id}"
  name = "load balancer name"
  dhcp = true
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| datacenter_id | Yes* | string | UUID of an existing Virtual Data Center resource. This parameters is not required if used under Server resource. |
| nic_id | Yes* | string | |
| dhcp | No | boolean | Indicates if the load balancer will reserve an IP using DHCP. |
| ip | No | string | IPv4 address of the load balancer. |

\* See the *Description* column for details.

**Please Note:** Due to a known issue with ProfitBricks Cloud API, the Terraform ProfitBricks Provider does not currently support creating Load Balancer objects. This should be resolved in the near future.

## ProfitBricks Data Sources

This section describes the various ProfitBricks data sources which allow ProfitBricks data to be fetched and used elsewhere in Terraform configuration.

### Data Centers Data Source

The data centers data source can be used to search for and return an existing Virtual Data Center. You can provide a string for the `name` and `location` parameters which will be compared with provisioned Virtual Data Centers. If a single match is found, it will be returned. If your search results in multiple matches, an error will be generated. When this happens, please refine your search string so that it is specific enough to return only one result.

#### Example Syntax

This example would search for Virtual Data Centers with the string "test_dc" in the *name* and "us/las" as the *location*.

```
data "profitbricks_datacenter" "dc_example" {
  name = "test_dc"
  location = "us/las"
}
```

#### Example Usage

If the example data center data source search above returned a valid result, it could be used later in the configuration. The following example code uses the returned value to provision a LAN resource inside the Virtual Data Center.

```
resource "profitbricks_lan" "webserver_lan" {
  datacenter_id = "${data.profitbricks_datacenter.dc_example.id}"
  public = true
  name = "public"
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes* | string | Name or part of the name of an existing Virtual Data Center that you want to search for. |
| location | No  | string | The id of the existing Virtual Data Center's location. [ "de/fkb", "de/fra", or "us/las"] |

If both parameters are provided the data source will use both to filter out the results.

### Images Data Source

The images data source can be used to search for and return an existing image which can then be used to provision a server.

#### Example Syntax

In this example, we will search for existing images that match our desired *name*, *type*, *version*, and *location*.

```
data "profitbricks_image" "image_example" {
  name = "Ubuntu"
  type = "HDD"
  version = "14"
  location = "location_id"
}
```

#### Example Usage

Once we have a valid result, we can make use of it when provisioning a new volume or server like this:

```
image_name = "${data.profitbricks_image.image_example.id}"
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | Name or part of the name of an existing image that you want to search for. |
| version | No | string | Version of the image (see details below). |
| location | No  | string | The id of the location of the image. [ "de/fkb", "de/fra", or "us/las"] |
| type | No  | string | The image type, HDD or CD-ROM. |

If both `name` and `version` are provided the plugin will concatenate the two strings in this format *[name]-[version]*.

### Locations Data Source

The locations data source can be used to search for and return an existing location which can then be used elsewhere in the configuration. There are currently three possible locations: "us/las", "de/fra", and "de/fkb".

#### Example Syntax

This example search would return a location matching "karls" that has the feature "SSD".

```
data "profitbricks_location" "loc1" {
  name = "karls"
  feature = "SSD"
}
```

Which should return the location id, "de/fkb", since that location has the name, "karlsruhe" and supports the feature, "SSD".

#### Example Usage

Once we have a valid location result, we can make use of it elsewhere in the configuration.

```
location = "${data.profitbricks_location.loc1.id}"
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | Name or part of the location name to search for. |
| feature | No  | string | A desired feature ["SSD", "MULTIPLE_CPU"] that the location must be able to provide. |

## Support

Additional information about the [Terraform CLI](https://www.terraform.io/docs/commands/index.html) is available.

You are welcome to contact us with questions or comments at [ProfitBricks DevOps Central](https://devops.profitbricks.com/). Please report any issues via [GitHub's issue tracker](https://github.com/ProfitBricks/terraform-provider-profitbricks/issues).
