
# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "somepassword"
  vsphere_server = "IP or DNS of your vCenter server"

  # set to true if you have a self-signed cert
  allow_unverified_ssl = true
}


# The number of VMs to deploy
# Don't forget to adjust the network settings below under "network" if you change the vmCount
locals {
  vmCount = 3
}

module "vsphereLinuxVM" {
  source           = "Terraform-VMWare-Modules/vm/vsphere"
  version          = "3.3.0"              # Version of VMware Terraform module
  dc               = "ASRock DC"          # vSphere DC name
  vmrp             = "Terraform"          # Resource Pool
  vmfolder         = "Terraform-VMs"      # VM folder
  datastore        = "vsanDatastore"      # What vSphere storage to use for the VMs
  vmtemp           = "ami2-template"      # Name of golden image VM to clone from
  instances        = local.vmCount        # Referencing local variable for number of VMs to create
  vmname           = "AMZN-AMI2-VM-"      # What to name VMs (number of VM as stated in "vmnameformat" below will be added at the end)
  vmnameformat     = "%02d"               # Format of number to add for VM count

  cpu_number       = 4
  ram_size         = 8192
  network = {                             # Network name and static IP addresses (use blank double quotations for DHCP: "")
    "name of your network or port group" = ["", "", ""]
  }
  ipv4submask      = ["24"]
  dns_server_list  = ["192.168.0.10", "192.168.0.1"]
  vmgateway        = "10.70.2.254"
  network_type     = ["vmxnet3"]
  domain           = "some.awesome.lab.com"
  scsi_bus_sharing = "noSharing"
  scsi_type        = "lsilogic-sas" // lsilogic-sas, lsilogic or pvscsi
  scsi_controller  = 0
  enable_disk_uuid = true
  orgname          = "Terraform-Module"
  is_windows_image = false
  firmware         = "bios"               # efi can also be used, but use bios for Amazon AMI2 image
}

output "vmnames" {
  value = module.vsphereLinuxVM.VM
}

output "vmip" {
  value = module.vsphereLinuxVM.ip
}
