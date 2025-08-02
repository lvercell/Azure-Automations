variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-avd-lab"
}

variable "vm_admin_username" {
  description = "Admin username for the Windows VM"
  type        = string
  default     = "azureuser"
}

variable "vm_admin_password" {
  description = "Admin password for the Windows VM"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "vm-avd-lab"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2ms"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-avd"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet-avd"
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-avd"
}

variable "public_ip_name" {
  description = "Name of the public IP"
  type        = string
  default     = "pip-avd"
}

variable "nic_name" {
  description = "Name of the network interface"
  type        = string
  default     = "nic-avd"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}
