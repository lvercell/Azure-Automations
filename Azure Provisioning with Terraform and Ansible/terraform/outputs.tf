output "resource_group_name" {
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "The name of the deployed Windows virtual machine"
  value       = azurerm_windows_virtual_machine.main.name
}

output "public_ip_address" {
  description = "The public IP address of the VM (for RDP or Bastion access)"
  value       = azurerm_public_ip.main.ip_address
}

output "rdp_port" {
  description = "Custom RDP port configured in the NSG"
  value       = "49999"
}
