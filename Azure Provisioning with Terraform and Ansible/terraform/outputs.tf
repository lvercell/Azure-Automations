output "resource_group_name" {
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "The name of the deployed Windows virtual machine"
  value       = azurerm_windows_virtual_machine.main.name
}


output "rdp_port" {
  description = "Custom RDP port configured in the NSG"
  value       = "49999"
}
