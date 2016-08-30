# ProfitBricks Provider

The ProfitBricks provider is used to interact with the many resources supported by ProfitBricks. Before you begin you will need to have [signed up for a ProfitBricks account.](https://www.profitbricks.com/signup). The credentials you create during sign-up will be used to authenticate against the API.

#Installation

Terraform must first be installed on your machine. Terraform is distributed as a [binary package](https://www.terraform.io/downloads.html) for all supported platforms and architecture.
To install Terraform, find the appropriate package for your system and download it. Terraform is packaged as a zip archive.

After downloading Terraform, unzip the package into a directory where Terraform will be installed. 

The final step is to make sure the directory you installed Terraform to is on the PATH.

Example for Linux/Mac - Type the following into your terminal:

```bash
PATH=/usr/local/terraform/bin:/home/your-user-name/terraform:$PATH
```
Example for Windows - Type the following into Powershell:

```powershell
set PATH=%PATH%;C:\terraform
```

After installing Terraform, verify the installation worked by opening a new terminal session and checking that terraform is available. By executing terraform you should see help output similar to that below:

```
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

##Download plugin binaries 

Download the desired binaries from https://github.com/profitbricks/terraform-provider-profitbricks/releases. Make sure that the binaries are available in the PATH.

```bash
PATH=/path/to/plugin:/usr/local/terraform/bin:/home/your-user-name/terraform:$PATH
```
Example for Windows - Type the following into Powershell:

```powershell
set PATH=%PATH%;C:\terraform;C:\path\to\plugin
```

##Build plugin from the source

Requirements [GO](https://golang.org/) 

Get the source code and execute the following: 

```
go get github.com/profitbricks/terraform-provider-profitbricks
```

Then run the command:

```
cd $GOPATH/github.com/profitbricks/terraform-provider-profitbricks
make install
```


# Plugin Usage
##Credentials

You can provide your credentials using the `PROFITBRICKS_USERNAME` and `PROFITBRICKS_PASSWORD` 
environment variables, representing your ProfitBricks username and password, respectively.


```
$ export PROFITBRICKS_USERNAME="profitbricks_username" 
$ export PROFITBRICKS_PASSWORD="profitbricks_password"
```

Or you can provide your credentials like this:

```
provider "profitbricks" {
    username = "profitbricks_username"
    password = "profitbricks_password"
    timeout = 100
}
```

Timeout describes number of retries while waiting for a resource to be provisioned. Default value is 50. 

#Simple example

In this example we will create a simple Virtual data center with an ubuntu server:

First create configuration directory:

```
mkdir ~/terraform
```

Change your current directory to the newly created directory:

```
cd ~/terraform
```

Create a text file with extension `.tf`:

```
vi main.tf
```

Copy following into main.tf:

```
//Virtual Data Center
resource "profitbricks_datacenter" "main" {
  name = "datacenter 01"
  location = "us/las"
  description = "description of the datacenter"
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
    size = 5
    disk_type = "SSD"
    ssh_key_path = "${var.private_key_path}"
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

Create variables.tf and add this into it:

```
Jasmins-MBP:temp jasmin$ cat variables.tf 
variable "ubuntu" {
  description = "Ubuntu Server"
  default = "ubuntu-16.04"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default = "/path/to/private/key"
}
```

Now you will want to see execution plan:

```
$terraform plan

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
    volume.2973529261.disk_type:                         "SSD"
    volume.2973529261.image_password:                    "test1234"
    volume.2973529261.licence_type:                      ""
    volume.2973529261.name:                              "system"
    volume.2973529261.nicHotPlug:                        "<computed>"
    volume.2973529261.nicHotUnplug:                      "<computed>"
    volume.2973529261.ramHotPlug:                        "<computed>"
    volume.2973529261.ramHotUnplug:                      "<computed>"
    volume.2973529261.size:                              "5"
    volume.2973529261.ssh_key_path:                      "/path/to/private/key"

```

After you have seen what Terraform will attempt to build the infrastructure run:

```
$terraform apply
```

You should see something like this: (truncated)
```
profitbricks_datacenter.main: Creating...
  description: "" => "description of the datacenter"
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
  volume.2973529261.disk_type:                        "" => "SSD"
  volume.2973529261.image_password:                   "" => "test1234"
  volume.2973529261.licence_type:                     "" => ""
  volume.2973529261.name:                             "" => "system"
  volume.2973529261.nicHotPlug:                       "" => "<computed>"
  volume.2973529261.nicHotUnplug:                     "" => "<computed>"
  volume.2973529261.ramHotPlug:                       "" => "<computed>"
  volume.2973529261.ramHotUnplug:                     "" => "<computed>"
  volume.2973529261.size:                             "" => "5"
  volume.2973529261.ssh_key_path:                     "" => "/path/to/private/key"
  ...
  ...
  Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

If you happen to get stuck, and Terraform is not working as you expect, you can start over by deleting the _terraform.tfstate_ file, and manually destroying the resources that were created usin ProfitBricks DCD.

If you want to see more information in the log run following command:

```
 export TF_LOG=1
```

If you wish to update one of the resources in the main.tf, just edit desired resource. For example let's rename the Virtual Data Center:

```
//Virtual Data Center
resource "profitbricks_datacenter" "main" {
  name = "datacenter"
  location = "us/las"
  description = "description of the datacenter"
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
    name: "datacenter 01" => "datacenter"

```

Terraform will inform you about change that will happen once you run `terraform apply`

To remove the infrastructure you have created run:

```
$ terraform destroy

Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 
```

This will remove the entire infrastructure defined in main.tf.

For more complex example see Example section below.


##ProfitBricks Resources

###Virtual Data Center

```
resource "profitbricks_datacenter" "example" {
  name = "datacenter name"
  location = "us/las"
  description = "datacenter description"
}
```

#### Argument Reference

The following arguments are supported:

* `name` - (Required)[string] The name of the Virtual Data Center.
* `location` - (Required)[string] The physical location where the data center will be created. 
* `description` - (Optional)[string] Description for the data center.

###Server

This resource will create an operational server. After this section completes, the provisioner can be called.

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

####Argument reference

* `name` - (Required) [string] The name of the server.
* `datacenter_id` - (Required)[string] 
* `cores` - (Required)[integer] Number of server cores.
* `ram` - (Required)[integer] The amount of memory for the server in MB.
* `availability_zone` - (Optional)[string] The availability zone in which the server should exist.
* `licence_type` - (Optional)[string] Sets the OS type of the server.
* `cpuFamily` - (Optional)[string] Sets the CPU type. "AMD_OPTERON" or "INTEL_XEON". Defaults to "AMD_OPTERON".
* `volume` -  (Required) See Volume section.
* `nic` - (Required) See NIC section.
* `firewall` - (Optional) See Firewall Rule section.

###Volume

A primary volume will be created with the server. If there is a need for additional volume, this resource handles it.

```
resource "profitbricks_volume" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  server_id = "${profitbricks_server.example.id}"
  image_name = "${var.ubuntu}"
  size = 5
  disk_type = "HDD"
  sshkey_path = "${var.private_key_path}"
  bus = "VIRTIO"
}
```

####Argument reference

* `datacenter_id` - (Required) [string] <sup>[1](#myfootnote1)</sup>
* `server_id` - (Required)[string] <sup>[1](#myfootnote1)</sup>
* `disk_type` - (Required) [string] The volume type, HDD or SSD.
* `bus` - (Required) [boolean] The bus type of the volume.
* `size` -  (Required)[integer] The size of the volume in GB.
* `image_password` - [string] Required if `sshkey_path` is not provided.
* `image_name` - [string] The image or snapshot ID. It is required if `licence_type` is not provided.
* `licence_type` - [string] Required if `image_name` is not provided.
* `name` - (Optional) [string] The name of the volume.

###NIC

```
resource "profitbricks_nic" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  server_id = "${profitbricks_server.example.id}"
  lan = 2
  dhcp = true
  ip = "${profitbricks_ipblock.example.ip}"
}
```

####Argument reference

* `datacenter_id` - (Required)[string]<sup>[1](#myfootnote1)</sup>
* `server_id` - (Required)[string]<sup>[1](#myfootnote1)</sup>
* `lan` - (Required) [integer] The LAN ID the NIC will sit on. 
* `name` - (Optional) [string] The name of the LAN.
* `dhcp` - (Optional) [boolean]
* `ip` - (Optional) [string] IP assigned to the NIC.
* `firewall_active` - (Optional) [boolean] If this resource is set to true and is nested under a server resource firewall, with open SSH port, resource must be nested under the nic.
	

### IP Block

```
resource "profitbricks_ipblock" "example" {
  location = "${profitbricks_datacenter.example.location}"
  size = 1
}
```

####Argument reference

* `location` - (Required)
* `size` - (Required)


###LAN

```
resource "profitbricks_lan" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  public = true
}
```

####Argument reference

* `datacenter_id` - (Required) [string]
* `name` - (Optional) [string] The name of the LAN
* `public` - (Optional) [Boolean] indicating if the LAN faces the public Internet or not.

Currently due to a known issue with ProfitBricks REST, Terraform ProfitBricks Provider doesn't allow creating multiple LAN objects.

###Firewall Rule

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

####Argument reference

* `datacenter_id` - (Required)[string]
* `server_id` - (Required)[string] 
* `nic_id` - (Required)[string] 
* `protocol` - (Required)[string] The protocol for the rule: TCP, UDP, ICMP, ANY.
* `name` - (Optional)[string] The name of the firewall rule.
* `source_mac` - (Optional)[string] Only traffic originating from the respective MAC address is allowed. Valid format: aa:bb:cc:dd:ee:ff.
* `source_ip` - (Optional)[string] Only traffic originating from the respective IPv4 address is allowed. 
* `target_ip` - (Optional)[string] Only traffic directed to the respective IP address of the NIC is allowed.
* `port_range_start` - (Optional)[string] Defines the start range of the allowed port (from 1 to 65534) if protocol TCP or UDP is chosen.
* `port_range_end` - (Optional)[string] Defines the end range of the allowed port (from 1 to 65534) if the protocol TCP or UDP is chosen.
* `icmp_type` - (Optional)[string] Defines the allowed type (from 0 to 254) if the protocol ICMP is chosen. 
* `icmp_code` - (Optional)[string] Defines the allowed code (from 0 to 254) if protocol ICMP is chosen.  



###Load Balancer

```
resource "profitbricks_loadbalancer" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  nic_id = "${profitbricks_nic.example.id}"
  name = "load balancer name"
  dhcp = true
}
```

####Argument reference

* `datacenter_id` - (Required)[string]
* `nic_id` - (Required)[string] 
* `dhcp` - (Optional) [boolean] Indicates if the load balancer will reserve an IP using DHCP.
* `ip` - (Optional) [string] IPv4 address of the load balancer.


###Example

You can get a working example [from the Github repository here](https://github.com/profitbricks/terraform-provider-profitbricks/tree/master/example). Just download the two files available and place them in a folder. Then, while located at the folder, run:

```
terraform plan 
```

Or to apply the configuration,  run:

```
terraform apply
```

This example will create a Virtual Data Center with a web server (nginx) and database server (mongodb).
Terraform will guide you throught the rest of the process. 

For details about the Terraform CLI please visit https://www.terraform.io/

#Support
You are welcome to contact us with questions or comments at [ProfitBricks DevOps Central](https://devops.profitbricks.com/). Please report any issues via [GitHub's issue tracker](https://github.com/profitbricks/terraform-provider-profitbricks/issues).

<a name="myfootnote1">1</a>: This parameters is not required if used under Server resource