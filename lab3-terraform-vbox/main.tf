terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

variable "vm_cpus" {
  type        = number
  description = "Number of CPUs per VM"
  default     = 6
}

variable "vm_memory" {
  type        = string
  description = "RAM per VM"
  default     = "4096 mib"
}

variable "vm_disk_size" {
  type        = string
  description = "Disk size in MB"
  default     = "20480"
}

variable "host_interface" {
  type        = string
  description = "VirtualBox host-only adapter name (check in VirtualBox settings)"
  default     = "VirtualBox Host-Only Ethernet Adapter"
}

resource "virtualbox_vm" "node" {
  count  = 2
  name   = format("terraform-vm-%02d", count.index + 1)
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
  cpus   = var.vm_cpus
  memory = var.vm_memory

  network_adapter {
    type           = "hostonly"
    host_interface = var.host_interface
  }
}

output "vm_names" {
  value = virtualbox_vm.node[*].name
}

output "vm_ips" {
  value = virtualbox_vm.node[*].network_adapter[0].ipv4_address
}
