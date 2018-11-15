variable "resource_group_name" {}

variable "resource_group_location" {
  default = "West Europe"
}

variable "vnet_name" {}

variable "subnet_name" {}

variable "network_security_group_name" {}

variable "network_interface_name" {}

variable "public_ip_name" {
}

variable "virtual_machine_name" {}

variable "virtual_machine_size" {
  default = "Standard_DS1_v2"
}

variable "admin_user" {
  default = "jbloggs"
}

variable "ssh_pub_key" {
}











