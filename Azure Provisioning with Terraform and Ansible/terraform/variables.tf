variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "westeurope"
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
